import 'dart:async';
import 'dart:html' as HTML;
import 'dart:io';

HTML.InputElement ToDoInput;
HTML.DivElement UIList;
HTML.ButtonElement ButtonClear;

List<ToDo> ToDoList = [];

Future main() async {

  // Setup the server
  HttpServer server;

  try {
    server = await HttpServer.bind('127.0.0.1', 8080);
  }
  catch (e){
    print("Failed to start server $e");
    exit(-1);
  }
  print('Listening on Localhost: ${server.port}');

  await for (var req in server) {
    HttpResponse response = req.response;
    response.headers.contentType = ContentType.html;

    if (req.method == 'GET'){
      String fileName;
      if (req.uri.pathSegments.length != 0){
        fileName = req.uri.pathSegments.last;
      }
      else{
        fileName = "index.html";
      }

      if(!fileName.contains('.html')){
        fileName += '.html';
      }

      File file = File(fileName);
      // If the file exists
      if (await file.exists()){
        // Make the file the response
        file.openRead().pipe(response);
      }
      // If the file doesn't exist
      else {
        file.openRead().pipe(response);
      }
    }
  }

  ToDoInput = HTML.querySelector('#todo');
  UIList = HTML.querySelector('#todo-list');
  ButtonClear = HTML.querySelector('#clear');

  ToDoInput.onChange.listen(AddToDo);
  ButtonClear.onClick.listen(RemoveAllToDos);
}

void AddToDo(HTML.Event event){
  ToDo toDo = ToDo(ToDoInput.value);
  ToDoList.add(toDo);

  UpdateToDos();
  ToDoInput.value = '';
}

void UpdateToDos(){
  UIList.children.clear();

  ToDoList.forEach((toDo){
    HTML.DivElement div = HTML.Element.div();
    HTML.ButtonElement buttonRemove = HTML.ButtonElement();
    HTML.Element span = HTML.Element.span();

    buttonRemove.text = '';
    buttonRemove.id = toDo.Text;
    buttonRemove.onClick.listen(RemoveToDo);

    span.text = toDo.Text;

    div.children.add(buttonRemove);
    div.children.add(span);
    UIList.children.add(div);
  });
}

void RemoveToDo(HTML.MouseEvent event){
  event.stopPropagation();
  HTML.Element div = (event.currentTarget as HTML.Element).parent;
  HTML.Element btn = (event.currentTarget as HTML.Element);

  int key = int.parse(btn.id.split('-')[0]);
  ToDoList.removeWhere((ToDo) => ToDo.ID == key);

  div.remove();
}

void RemoveAllToDos(HTML.MouseEvent event){
  UIList.children.clear();
  ToDoList.clear();
}


class ToDo {
  int ID = 0;
  String Text;

  ToDo(text){
    this.Text = text;
  }

}