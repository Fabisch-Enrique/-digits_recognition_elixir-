defmodule Digits.Model do
  @moduledoc"""
  This is the Digits Machine Learning Model
  """
  require Axon
  
#extracting the dataset from the Scidata package
  def download do
    Scidata.MNIST.download()
  end

  # the data comes as a tuple of images and labels {images, labels}
  def transform_images({binary, type, shape}) do
    binary
    |> Nx.from_binary(type)
    |> Nx.reshape(shape)
    |> Nx.divide(255)
  end

  def transform_labels(binary, type, _) do
    binary
    |> Nx.from_binary(type)
    |> Nx.new_axis(-1)
    |> Nx.equal(Nx.tensor((Enum.to_list(0..9))))
  end


  #converting images and labels into batches, for feeding data into the model.

  batch_size = 32

  images =
    images
    |> Digits.Model.transform_images()
    |> Nx.to_batched_list(batch_size)


  labels =
    labels
    |> Digits.Model.transform_labels()
    |> Nx.to_batched_list(batch_size)


  #zip images and labels using (Enum.zip) then split using (Enum.split) the data into TRAINING, TESTING AND VALIDATION. majority of the data is used for training. 80%

  data = Enum.zip(images, labels)

  training_count_data = floor(0.8 * Enum.count(data))
  validation_count_data = floor(0.2 * training_count_data)

  {training_data, test_data} = Enum.split(data, training_count_data)
  {validation_data, training_data} = Enum.split(train, validation_count_data)

  #building the model
  def new({channels, height, width}) do
    #set the input shape of the model to fit our training data
    Axon.input({nil, channels, height, width})
    |> Axon.flatten()
    |> Axon.dense(128, activation: :relu)
    |> Axon.dense(10, activation: :softmax)
  end

  #training the model
  def train(model, training_data, validation_data) do
    model
    |> Axon.Loop.trainer(:categorical_cross, Axon.Optimizers.adam(0.01))
    |> Axon.Loop.metric(:accuracy, "Accuracy")
    |> Axon.Loop.validate(model, validation_data)
    |> Axon.Loop.run(training_data, compiler: EXLA. epochs: 10)
  end

  #testing the model
  def test(model, state, test_data) do
    model
    |> Axon.Loop.evaluator(state)
    |> Axon.Loop.metric(:accuraxy, "Accuracy")
    |> Axon.Loop.run(test_data)
  end

  #saving and loading our model
  def save!(model, state) do
    contents = :erlang.term_to_binary(model, state)

    File.write(path(), contents)
  end

  def load! do
    path()
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  def path do
    Path.join(Application.app_dir(:digits, "priv"), "model.axon")
  end

  #adding the function that does the prediction
  def predict(path) do

    #First, we read the image path and convert it to grayscale. This reduces the number of channels from 3 to 1. Then we resize the image to 28 x 28.
    {:ok, mat} = Evision.imread(path, flags: Evision.cv_IMREAD_GRAYSCALE)
    {:ok, mat} = Evision.resize(mat, [28, 28])

    #We also need to convert the image data to an Nx tensor and reshape it to an expected correct shape. Our machine learning model expects a "batch" of inputs
    data =
      Evision.Nx.to_nx(mat)
      |> Nx.reshape({1, 28, 28})
      |> List.wrap()
      |> Nx.stack()

    {model, state} = load!()

    model
    |> Axon.predict(state, data, compiler: EXLA)
    |> Nx.argmax()
    |> Nx.to_number()
  end
end
