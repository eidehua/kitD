# kitD
Detecting Male vs female cats using facial recognition


## Kittydar Neural Network Instructions

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
node test-nn.js -p ../images/test-male -n ../images/test-female
```

#### Test neural network
```bash
node test-nn.js -p ../images/test-male -n ../images/test-female
```