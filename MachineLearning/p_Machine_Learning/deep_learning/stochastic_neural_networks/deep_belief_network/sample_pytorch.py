import torch
from torch import nn
import numpy as np
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler
from torch.utils.data import TensorDataset, DataLoader, Dataset
from sklearn.metrics import mean_squared_error
from torch.optim import Adam

class RBM(nn.Module):
    def __init__(self, visible_units=256, hidden_units=64, output_units=1, kernel=1, batch_size=16, learning_rate=1e-5):
        super(RBM, self).__init__()
        self.visible_units = visible_units
        self.hidden_units = hidden_units
        self.output_units = output_units
        self.kernel = kernel
        self.learning_rate = learning_rate
        self.batch_size = batch_size

        # initialize 
        self.activation = torch.nn.Sigmoid()
        self.activation_name = self.activation.__class__.__name__.lower()
        self.weight = nn.Parameter(torch.rand(self.visible_units, self.hidden_units))
        self.v_bias = nn.Parameter(torch.rand(self.visible_units))
        self.h_bias = nn.Parameter(torch.rand(self.hidden_units))

        # params
        nn.init.xavier_uniform_(self.weight, nn.init.calculate_gain(self.activation_name))
        nn.init.zeros_(self.v_bias)
        nn.init.zeros_(self.h_bias)

    def to_hidden(self, vis_prob):
        # Calculate hid_prob
        hid_prob = torch.matmul(vis_prob, self.weight)
        hid_prob = torch.add(hid_prob, self.h_bias)
        hid_prob = self.activation(hid_prob)
        hid_sample = torch.bernoulli(hid_prob)
        return hid_prob, hid_sample

    def to_visible(self, hid_prob):
        # Computing hidden activations and then converting into probabilities
        vis_prob_recon = torch.matmul(hid_prob, self.weight.transpose(0, 1))
        vis_prob_recon = torch.add(vis_prob_recon, self.v_bias)
        vis_prob_recon = self.activation(vis_prob_recon)
        vis_sample = torch.bernoulli(vis_prob_recon)
        return vis_prob_recon, vis_sample

    def reconstruct(self, vis_prob, n_gibbs):
        vis_sample = torch.rand(vis_prob.size(), device="cpu")
        
        for i in range(n_gibbs):
            hid_prob, hid_sample = self.to_hidden(vis_prob)
            vis_prob, vis_sample = self.to_visible(hid_prob)

        return vis_prob, vis_sample

    def forward(self, input_data):
        return self.to_hidden(input_data)

    def backward(self, input_data):
        # Positive phase
        positive_hid_prob, positive_hid_dis = self.to_hidden(input_data)

        # Calculate energy via positive side
        positive_associations = torch.matmul(input_data.t(), positive_hid_dis)

        # Negative phase
        hidden_activations = positive_hid_dis
        vis_prob = torch.rand(input_data.size(), device="cpu")
        hid_prob = torch.rand(positive_hid_prob.size(), device="cpu")
        for i in range(self.kernel):
            vis_prob, _ = self.to_visible(hidden_activations)
            hid_prob, hidden_activations = self.to_hidden(vis_prob)

        negative_vis_prob = vis_prob
        negative_hid_prob = hid_prob

        # Calculating w via negative side.
        negative_associations = torch.matmul(negative_vis_prob.t(), negative_hid_prob)

        # Update parameters
        grad_update = 0
        batch_size = self.batch_size
        g = positive_associations - negative_associations
        grad_update = g / batch_size
        v_bias_update = (torch.sum(input_data - negative_vis_prob, dim=0) / batch_size)
        h_bias_update = torch.sum(positive_hid_prob - negative_hid_prob, dim=0) / batch_size

        # Attention: While applying in-place operation to a leaf Variable.
        self.weight.data += self.learning_rate * grad_update
        self.v_bias.data += self.learning_rate * v_bias_update
        self.h_bias.data += self.learning_rate * h_bias_update

        # Compute reconstruction mse error
        error = torch.mean(
            torch.sum((input_data - negative_vis_prob) ** 2, dim=0)
        ).item()
        
        return error, torch.sum(torch.abs(grad_update)).item()

    def train(self, train_dataloader, n_epochs=50):
        for epoch in range(1, n_epochs + 1):
            n_batches = len(train_dataloader)
            cost_ = torch.FloatTensor(n_batches, 1)
            grad_ = torch.FloatTensor(n_batches, 1)

            # Train_loader contains input and output data. 
            # However, training of RBM doesn't require output data.
            for i, batch in enumerate(train_dataloader):
                cost_[i - 1], grad_[i - 1] = self.backward(batch[0])

            loss = torch.mean(cost_)
            print(f"\r[{epoch}/{n_epochs}] loss:{loss}", end="")
        print("\n")

class DBN(nn.Module):
    def __init__(self, input_units, hidden_units, output_units, loss_function=torch.nn.MSELoss(), optimizer=torch.optim.Adam, learning_rate=1e-5, kernel=2):
        super(DBN, self).__init__()
        self.n_layers = len(hidden_units)
        self.layers = []

        # create RBM layers
        for i in range(self.n_layers):
            n_input = input_units if i == 0 else hidden_units[i - 1]
            self.layers.append( RBM(n_input, hidden_units[i], output_units, kernel=kernel, learning_rate=learning_rate) )

        # set parameters
        self.W    = [self.layers[i].weight for i in range(len(self.layers))]
        self.bias = [self.layers[i].h_bias for i in range(len(self.layers))]
        for i in range(len(self.layers)):
            self.register_parameter('W%i' % i, self.W[i])
            self.register_parameter('bias%i' % i, self.bias[i])

        self.bpnn = torch.nn.Linear(hidden_units[-1], output_units)
        self.loss_function = loss_function
        self.optimizer = optimizer(self.parameters())

    def forward(self, X):
        outputs = X

        for layer in self.layers:
            outputs, _ = layer.to_hidden(outputs)
        
        return self.bpnn(outputs)

    def predict(self, x, batch_size, shuffle=False):
        y_predict = torch.tensor([])

        x_tensor = torch.tensor(x, dtype=torch.float, device="cpu")
        dataset = TensorDataset(x_tensor)
        dataloader = DataLoader(dataset, batch_size, shuffle)
        with torch.no_grad():
            for batch in dataloader:
                y = self.forward(batch[0])
                y_predict = torch.cat((y_predict, y.cpu()), 0)

        return y_predict.flatten()

    def reconstruct(self, input_data):
        h = input_data
        p_h = 0
        for i in range(len(self.layers)):
            # h = h.view((h.shape[0], -1))
            p_h, h = self.layers[i].to_hidden(h)

        for i in range(len(self.layers) - 1, -1, -1):
            # h = h.view((h.shape[0], -1))
            p_h, h = self.layers[i].to_visible(h)
        return p_h, h

    def train(self, x, y, n_epochs, batch_size, shuffle=True):
        output = torch.tensor(x, dtype=torch.float, device="cpu")

        for i, layer in enumerate(self.layers):
            print("Training RBM layer {}.".format(i + 1))

            dataset_i = TensorDataset(output)
            dataloader_i = DataLoader(dataset_i, batch_size=batch_size, drop_last=False)

            layer.train(dataloader_i, n_epochs)
            output, _ = layer.forward(output)

        dataset = FineTuningDataset(x, y)
        dataloader = DataLoader(dataset, batch_size, shuffle=shuffle)

        print('Train DBN network')
        for epoch in range(1, n_epochs + 1):
            loss_batch = 0
            for batch in dataloader:
                # forward pass
                input_data, ground_truth = batch
                output = self.forward(input_data)
                loss = self.loss_function(ground_truth, output)
                
                # backward pass
                self.optimizer.zero_grad()
                loss.backward()
                self.optimizer.step()
                loss_batch += loss.item()

            print(f"\r[{epoch}/{n_epochs}] loss batch:{loss_batch}", end="")

class FineTuningDataset(Dataset):
    """
    Dataset class for whole dataset. x: input data. y: output data
    """
    def __init__(self, x, y):
        self.x = x.astype(np.float32)
        self.y = y.astype(np.float32)

    def __getitem__(self, index):
        return self.x[index], self.y[index]

    def __len__(self):
        return len(self.x)

class Data:
    def __init__(self):
        self.scaler = StandardScaler()

    def get_data(self, input_length=50, output_length=1, procent_test=0.2):
        # data
        data = 2 * np.sin([i / 2000 * 50 * np.pi for i in range(2000)]) + 5
        data = self.scaler.fit_transform(data.reshape(-1, 1)).flatten()#[-1 t/m 1]

        dataset = []
        for i in range(len(data) - input_length - output_length):
            dataset.append(data[i:i + input_length + output_length])
        
        # separate data
        dataset = np.array(dataset)
        dataset_train = dataset[:int(len(dataset) * (1 - procent_test)) ]
        dataset_test  = dataset[ int(len(dataset) * (1 - procent_test)):]

        x_train = dataset_train[:, :-1]
        y_train = dataset_train[:, -1:]
        x_test = dataset_test[:, :-1]
        y_test = dataset_test[:, -1:]
        return (x_train, y_train), (x_test, y_test)

if __name__ == "__main__":
    n_input_units = 50
    n_hidden_units = [128, 64]
    n_output_units = 1
    batch_size = 128
    n_epochs = 200

    # dataset
    dataHandler = Data()
    (x_train, y_train), (x_test, y_test) = dataHandler.get_data(n_input_units, n_output_units, procent_test=0.2)

    # define network
    network = DBN(n_input_units, n_hidden_units, n_output_units)

    # train network
    network.train(x_train, y_train, n_epochs, batch_size)

    # network results
    y_predict = network.predict(x_test, batch_size)
    y_real = dataHandler.scaler.inverse_transform(y_test.reshape(-1, 1)).flatten()
    y_predict = dataHandler.scaler.inverse_transform(y_predict.reshape(-1, 1)).flatten()

    ####################################################################################################

    print('x_train.shape:' + str(x_train.shape))
    print('y_train.shape:' + str(y_train.shape))
    print('x_test.shape:' + str(x_test.shape))
    print('y_test.shape' + str(y_test.shape))

    plt.figure(1)
    plt.plot(y_real, label='real')
    plt.plot(y_predict, label='prediction')
    plt.xlabel('MSE Error: {}'.format(mean_squared_error(y_real, y_predict)))
    plt.legend()
    plt.title('Prediction result')
    plt.show()