# Dalila
Dalila is a machine learning model management and benchmarking platform for deploying and training models,
making automated predictions and analyzing model metrics.

## Requirements
- Build-essential - To use the Make commands.
- Docker (version 24) - To launch containers.

## Installation
1. Clone this source code repository - ssh method :
   ```bash
   git clone git@github.com:dalila-mlp/client.git
   ```

2. Access the project directory :
   ```bash
   cd dalila
   ```

## Start
1. To start the project, simply run this command :
   ```bash
   make start
   ```

2. Open your browser and go to the following URL to access the client :
   ```
   http://localhost:5000
   ```

   You should now be able to see the web client in action!

3. Open your browser and go to the following URL to access the api :
   ```
   http://localhost:80
   ```

   You should now be able to see the api in action!

4. Open your browser and go to the following URL to access the postgre admin :
   ```
   http://localhost:5432
   ```

   You should now be able to see the postgre admin in action!

---

We hope this guide has helped you get started with the dalila project to deploy, train and make predictions intuitively.
If you have any further questions, please don't hesitate to ask.
