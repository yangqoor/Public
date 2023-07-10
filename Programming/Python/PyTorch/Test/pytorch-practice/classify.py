import torch
import torch.nn.functional as F
import matplotlib.pyplot as plt
import os

os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'


n_data = torch.ones(100, 2)
x0 = torch.normal(2*n_data, 1)
y0 = torch.zeros(100)
x1 = torch.normal(-2*n_data, 1)
y1 = torch.ones(100)
# x2 = x0
# x2[:, 1] = x1[:, 1]
# y2 = 2 * y1

x = torch.cat((x0, x1)).type(torch.FloatTensor)
y = torch.cat((y0, y1)).type(torch.LongTensor)

# print(x.shape, y.shape)

# plt.scatter(x.data.numpy()[:, 0], x.data.numpy()[:, 1], c=y.data.numpy(), s=100, lw=0, cmap='RdYlGn')
# plt.show()


class Net(torch.nn.Module):
    # def __init__(self, n_feature, n_hidden, n_output):
    #     super(Net, self).__init__()
    #     self.n_hidden = torch.nn.Linear(n_feature, n_hidden)
    #     self.out = torch.nn.Linear(n_hidden, n_output)

    def __init__(self, n_feature, n_hidden, n_output):
        super(Net, self).__init__()
        self.classify = torch.nn.Sequential(
            torch.nn.Linear(n_feature, n_hidden),
            torch.nn.ReLU(),
            torch.nn.Linear(n_hidden, n_output),
        )

    def forward(self, x_layer):
        # x_layer = torch.relu(self.n_hidden(x_layer))
        # x_layer = self.out_layer)
        x_layer = self.classify(x_layer)
        x_layer = torch.nn.functional.softmax(x_layer)
        return x_layer


net = Net(n_feature=2, n_hidden=10, n_output=2)
# print(net)

optimizer = torch.optim.SGD(net.parameters(), lr=0.02)
loss_func = torch.nn.CrossEntropyLoss()

for i in range(100):
    out = net(x)
    # print(out.shape, y.shape)
    loss = loss_func(out, y)

    optimizer.zero_grad()
    loss.backward()
    optimizer.step()


# train result
train_result = net(x)
# print(train_result.shape)
train_predict = torch.max(train_result, 1)[1]
plt.scatter(x.data.numpy()[:, 0], x.data.numpy()[:, 1], c=train_predict.data.numpy(), s=100, lw=0, cmap='RdYlGn')
plt.show()


# test
t_data = torch.zeros(100, 2)
test_data = torch.normal(t_data, 5)
test_result = net(test_data)
prediction = torch.max(test_result, 1)[1]

plt.scatter(test_data[:, 0], test_data[:, 1], s=100, c=prediction.data.numpy(), lw=0, cmap='RdYlGn')
plt.show()
