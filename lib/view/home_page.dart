import 'package:bahar_firebase_case/model/kisi.dart';
import 'package:bahar_firebase_case/service/auth_service.dart';
import 'package:bahar_firebase_case/view/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

 AuthService authService = AuthService();

 List<Kisi> kisiler = [];

 final kisilerInstance = FirebaseFirestore.instance.collection("kisiler");
 //List<Kisi> kisiler = [];

 Future<void> fetchKisiler() async{
  var response = await kisilerInstance.get();
  mapKisiler(response);
 }

 Future<void> mapKisiler(QuerySnapshot<Map<String, dynamic>> datas) async{
  var data = datas.docs.map((e) => 
  Kisi(id: e.id, name: e["name"], num: e["num"])
  ).toList();

  setState(() {
    kisiler = data;
  });
 }

 Future<void> addKisi(String name, String num)async{
  var newKisi = Kisi(id: "",name: name, num: num);
 await FirebaseFirestore.instance.collection("kisiler").add(newKisi.toJson());
 }

 Future<void> deleteKisi(String id)async{
 await FirebaseFirestore.instance.collection("kisiler").doc(id).delete();
 }

 Future<void> updateKisi(String id,String name, String num)async{
  var newKisi = Kisi(id: "",name: name, num: num);
  await FirebaseFirestore.instance.collection("kisiler").doc(id).update(newKisi.toJson());

 }

 var nameController = TextEditingController();
 var numController = TextEditingController();
 void addKisiDialog(){
   showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(

    title: Text("Kişi Ekleme"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      TextFormField(controller: nameController,decoration: InputDecoration(hintText: "İsim"),),
      TextFormField(controller: numController,decoration: InputDecoration(hintText: "Numara"),),
      
    ],),
    actions: [
      TextButton(onPressed: (){
        clear();
      }, child: Text("Temizle")),
 
      TextButton(onPressed: (){
        addKisi(nameController.text, numController.text);
        clear();
        Navigator.pop(context);
      }, child: Text("Ekle")),

    ],
      );
    },);
 }

 void updateKisiDialog(String id,String name, String num){
   showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(

    title: Text("Güncelleme"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      TextFormField(controller: nameController,decoration: InputDecoration(hintText: "İsim"),),
      TextFormField(controller: numController,decoration: InputDecoration(hintText: "Numara"),),
      
    ],),
    actions: [
      TextButton(onPressed: (){
        clear();
      }, child: Text("Temizle")),
 
      TextButton(onPressed: (){
        updateKisi(id,nameController.text, numController.text);
        clear();
        Navigator.pop(context);
      }, child: Text("Güncelle")),

    ],
      );
    },);
 }
 
 void clear(){
 setState(() {
   nameController.text = "";
   numController.text = "";
 });
 }

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchKisiler();
    FirebaseFirestore.instance.collection("kisiler").snapshots().listen((event) {
      mapKisiler(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("CurrentUser : " + authService.authInstance.currentUser.toString());
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,title: Text("Rehberim"),actions: [
        IconButton(onPressed: (){
          authService.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        }, icon: Icon(Icons.door_sliding_sharp))
      ],),

      body:
       kisiler.length==0 ? 
       Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           Center(child: Container(child: CircularProgressIndicator(),)),
         ],
       )
       :
       Column(

        children: [
            Expanded(
              child: ListView.builder(itemCount: kisiler.length,itemBuilder: (context,index){
                return ListTile(
            
                  title: Text(kisiler[index].name),
                  subtitle: Text(kisiler[index].num),
                  trailing: 
                      Container(
                       // decoration: BoxDecoration(border: Border.all(width: 1)),
                        width: MediaQuery.of(context).size.width*0.25,
                        height: MediaQuery.of(context).size.height*0.07,
                        child: Row(
                          children: [
                            IconButton(onPressed: (){
                              updateKisiDialog(kisiler[index].id,kisiler[index].name, kisiler[index].num);
                            }, icon: Icon(Icons.update)),
                            IconButton(onPressed: (){
                              deleteKisi(kisiler[index].id);
                            }, icon: Icon(Icons.delete)),

                          ],
                        ),
                      )
                    
            
                )
                
                
                /*Slidable(
  // Specify a key if the Slidable is dismissible.
  key: const ValueKey(0),

  // The end action pane is the one at the right or the bottom side.
  endActionPane: const ActionPane(
    motion: ScrollMotion(),
    children: [
      SlidableAction(
        // An action can be bigger than the others.
        flex: 2,
        onPressed: deleteKisi(kisiler[index].id,context),
        backgroundColor: Color.fromARGB(255, 253, 1, 1),
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),

      SlidableAction(
        onPressed: doNothing,
        backgroundColor: Color.fromARGB(255, 3, 207, 105),
        foregroundColor: Colors.white,
        icon: Icons.icecream,
        label: 'Update',
      ),
    ],
  ),

  // The child of the Slidable is what the user sees when the
  // component is not dragged.
  child: ListTile(
            
                  title: Text(kisiler[index].name),
                  subtitle: Text(kisiler[index].num),
            
                )
)*/
;

                
                
                
                
                
                
              }),
            )
        ],
      ),


      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: (){
        addKisiDialog();
      }),
    );

    
  }
}