# Neural Tuning Machine (NTM)
A `Neural Turing Machine` is a working memory neural network model. It couples a neural network architecture with external memory resources. The whole architecture is differentiable end-to-end with gradient descent. The models can infer tasks such as copying, sorting and associative recall.

A `Neural Turing Machine (NTM)` architecture contains two basic components: a neural network controller and a memory bank. The Figure presents a high-level diagram of the `NTM` architecture. Like most neural networks, the controller interacts with the external world via input and output vectors. Unlike a standard network, it also interacts with a memory matrix using selective read and write operations. By analogy to the Turing machine we refer to the network outputs that parameterise these operations as “heads.”

Every component of the architecture is differentiable. This is achieved by defining 'blurry' read and write operations that interact to a greater or lesser degree with all the elements in memory (rather than addressing a single element, as in a normal Turing machine or digital computer). The degree of blurriness is determined by an attentional “focus” mechanism that constrains each read and write operation to interact with a small portion of the memory, while ignoring the rest. Because interaction with the memory is highly sparse, the `NTM` is biased towards storing data without interference. The memory location brought into attentional focus is determined by specialised outputs emitted by the heads. These outputs define a normalised weighting over the rows in the memory matrix (referred to as memory “locations”). Each weighting, one per read or write head, defines the degree to which the head reads or writes at each location. A head can thereby attend sharply to the memory at a single location or weakly to the memory at many locations

Nowadays the Tansformers are very popular any promissing models that can can fix wide range of problems.  
They are partly based on this model.

<!-- https://github.com/nerdimite/ntm -->
<!-- https://github.com/MarkPKCollier/NeuralTuringMachine -->
## code 
<!-- [`python3 sample_keras.py`](./sample_keras.py)       -->
[`python3 sample_pytorch.py`](./sample_pytorch.py)  
<!-- [`python3 sample_scratch.py`](./sample_scratch.py)   -->

<p align="center">
  <img src="https://miro.medium.com/max/3256/1*mGoSlTKnPKcykWp0VYSqkw.png"  width="500px">
</p>
<p align="center">
  <img src="https://image.slidesharecdn.com/neuralturingmachines-150104010840-conversion-gate01/95/neural-turing-machines-7-638.jpg?cb=1420333769"  width="500px">
</p>
<p align="center">
  <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3FHUJAZL-EgnfoLZNMRV6g9rDZzX17aeLFg&usqp=CAU"  width="500px">
</p>

## Usefull Resources:
+ https://www.youtube.com/watch?v=XBgwq4IePLw
+ https://www.youtube.com/watch?v=Q57rzaHHO0k
+ https://clemkoa.github.io/paper/2020/05/27/neural-turing-machines-pytorch.html
+ https://rylanschaeffer.github.io/content/research/neural_turing_machine/main.html
+ https://arxiv.org/pdf/1410.5401v2.pdf (recommended)
+ https://arxiv.org/abs/1706.03762
+ https://arxiv.org/pdf/1807.03819.pdf (transformers are invented from these)