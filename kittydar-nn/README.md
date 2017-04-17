# Kittydar Neural Network Instructions

#### Enter Kittydar NN directory
```bash
cd kittydar-nn
```

#### Install dependencies
```bash
npm install
```

#### Train neural network 
You can change neural network setting by modifying `params` in `train-nn.js`
```bash
node train-nn.js -p ../images/train-male -n ../images/train-female
```

#### Test neural network
```bash
node test-nn.js -p ../images/test-male -n ../images/test-female
```