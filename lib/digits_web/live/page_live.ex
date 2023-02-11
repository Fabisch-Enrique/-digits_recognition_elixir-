defmodule DigitsWeb.PageLive do
  @moduledoc """
  PageLIve LiveView
  """

  use DigitsWeb, :LiveView

  def mount(_params, _session, socket) do
    {:ok,
      assign(socket, %{prediction: nil})}
  end

  def handle_event("reset", _params, socket) do
    {:noreply
      socket
      |> assign(prediction: nil)
      |> push_event("reset", %{})
    }
  end

  def handle_event("predict", _params, socket) do
    {:noreply, push_event(socket, "predict", %{})}
  end

  #we will now use the image from the canvas as a new input to our mchine learning model
  #we can accept image data URL from the client using another handle_event/3 callback function
  def handle_event("image", "data:image/png;base64," <> raw, socket) do

    #binary pattern matching on the params to get the image data.
    name = Base.url_decode64!(:crypto.strong_rand_bytes(10), padding: false)
    path = Path.join(System.tmp_dir!(), "#{name}.png")

    #we generate a random file name and create a path to a temporary directory for storing the image, then decode the image data and write it to the path
    File.write!(path, Base.decode64!(raw))

    #pass the path into the Digits.Model.predict/1 function and return a prediction.
    prediction = Digits.Model.predict(path)

    #Finally, we delete the image file and assign the prediction to the socket for display in our LiveView.
    File.rm!(path)

    {:noreply,
      |> assign(socket, prediction: prediction)}
  end


  """BEFORE WE CAN USE THE USER'S DRAWING together WITH OUR MODEL WE NEED TO PREPARE THE IMAGE
      1) We need to convert it tograyscale to reduce the number channels from 3 to 1
      2) We need to resize it to 28*28

      The Evision library can do these changes for us, let's add this dependency
  """
end
