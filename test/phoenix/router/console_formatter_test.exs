defmodule Phoenix.Router.ConsoleFormatterTest do
  use ExUnit.Case, async: true
  alias Phoenix.Router.ConsoleFormatter

  defmodule RouterTestSingleRoutes do
    use Phoenix.Router

    get "/", Phoenix.PageController, :index, as: :page
    post "/images", Phoenix.ImageController, :upload, as: :upload_image
    delete "/images", Phoenix.ImageController, :delete, as: :remove_image
  end

  test "format multiple routes" do
    assert draw(RouterTestSingleRoutes) == """
            page_path  GET     /        Phoenix.PageController :index
    upload_image_path  POST    /images  Phoenix.ImageController :upload
    remove_image_path  DELETE  /images  Phoenix.ImageController :delete
    """
  end

  defmodule RouterTestResources do
    use Phoenix.Router
    resources "/images", Phoenix.ImageController
  end

  test "format resource routes" do
    assert draw(RouterTestResources) == """
    image_path  GET     /images           Phoenix.ImageController :index
    image_path  GET     /images/:id/edit  Phoenix.ImageController :edit
    image_path  GET     /images/new       Phoenix.ImageController :new
    image_path  GET     /images/:id       Phoenix.ImageController :show
    image_path  POST    /images           Phoenix.ImageController :create
    image_path  PATCH   /images/:id       Phoenix.ImageController :update
                PUT     /images/:id       Phoenix.ImageController :update
    image_path  DELETE  /images/:id       Phoenix.ImageController :delete
    """
  end

  defmodule RouterTestResource do
    use Phoenix.Router
    resources "/image", Phoenix.ImageController, singleton: true
    forward "/admin", RouterTestResources, [], as: :admin
    forward "/f1", RouterTestSingleRoutes
  end

  test "format single resource routes" do
    assert draw(RouterTestResource) == """
    image_path  GET     /image/edit  Phoenix.ImageController :edit
    image_path  GET     /image/new   Phoenix.ImageController :new
    image_path  GET     /image       Phoenix.ImageController :show
    image_path  POST    /image       Phoenix.ImageController :create
    image_path  PATCH   /image       Phoenix.ImageController :update
                PUT     /image       Phoenix.ImageController :update
    image_path  DELETE  /image       Phoenix.ImageController :delete
                *       /admin       Phoenix.Router.ConsoleFormatterTest.RouterTestResources []
                *       /f1          Phoenix.Router.ConsoleFormatterTest.RouterTestSingleRoutes []
    """
  end

  describe "endpoint sockets" do

    def __sockets__, do: []

    defmodule FormatterEndpoint do
      use Phoenix.Endpoint, otp_app: :phoenix

      socket "/socket", TestSocket, websocket: true
    end

    test "format endpoint sockets" do
      assert draw(RouterTestSingleRoutes, FormatterEndpoint) == """
              page_path  GET     /        Phoenix.PageController :index
      upload_image_path  POST    /images  Phoenix.ImageController :upload
      remove_image_path  DELETE  /images  Phoenix.ImageController :delete

      Phoenix.Router.ConsoleFormatterTest.FormatterEndpoint sockets:

              websocket          /socket  TestSocket
               longpoll          /socket  TestSocket
      """
    end


    test "format endpoint without sockets" do
      assert draw(RouterTestSingleRoutes, __MODULE__) == """
              page_path  GET     /        Phoenix.PageController :index
      upload_image_path  POST    /images  Phoenix.ImageController :upload
      remove_image_path  DELETE  /images  Phoenix.ImageController :delete
      """
    end
  end

  defp draw(router, endpoint \\ nil) do
    ConsoleFormatter.format(router, endpoint)
  end
end
