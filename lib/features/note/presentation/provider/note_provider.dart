import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:simple_dapp/features/note/data/model/note_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
class NoteService extends ChangeNotifier{
  List<Note> notes = [];
  final String _rpcUrl =  Platform.isAndroid ? 'http://10.0.2.2:7545' : 'http://127.0.0.1:7545';
  final String _wsUrl =   Platform.isAndroid ? 'http://10.0.2.2:7545' : 'ws://127.0.0.1:7545';
  final String _privatekey =
      '366b9279d34e610885020543537fb648c4f679ce553f3294e2bec1210ebac7d0';


  bool isLoading = true;

  // late ContractAbi _abiCode;
  // late EthereumAddress _contractAddress;
  late Web3Client web3client;
  // late EthPrivateKey _creds;
  //
  // late DeployedContract _deployedContract;
  // //Contract function
  // late ContractFunction _createNote;
  // late ContractFunction _deleteNote;
  // late ContractFunction _notes;
  // late ContractFunction _noteCount;

  NoteService(){
    init();
  }

  Future<void> init() async {
   web3client = Web3Client(
      _rpcUrl,
      http.Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
    );
   await getABI();
   await getCredentials();
   await getDeployedContract();
  }

  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;
  Future<void> getABI()async{
      String abiFile =
      await rootBundle.loadString('build/contracts/NoteContract.json');
      var jsonABI = jsonDecode(abiFile);
      _abiCode =
          ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'NoteContract');
      _contractAddress =
          EthereumAddress.fromHex(jsonABI["networks"]["5777"]["address"]);
    }

  late EthPrivateKey _creds;
  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privatekey);
  }

  late DeployedContract _deployedContract;
  late ContractFunction _createNote;
  late ContractFunction _deleteNote;
  late ContractFunction _updateNote;
  late ContractFunction _notes;
  late ContractFunction _noteCount;
  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(_abiCode, _contractAddress);
    _createNote = _deployedContract.function('createNote');
    _deleteNote = _deployedContract.function('deleteNote');
    _updateNote = _deployedContract.function('updateNote');
    _notes = _deployedContract.function('notes');
    _noteCount = _deployedContract.function('noteCount');
    await fetchNotes();
  }

  Future<void> fetchNotes() async{
    List totalTaskList = await web3client.call(
      contract: _deployedContract,
      function: _noteCount,
      params: [],
    );

    int totalTaskLen = totalTaskList[0].toInt();
    notes.clear();
    for (var i = 0; i < totalTaskLen; i++) {
      var temp = await web3client.call(
          contract: _deployedContract,
          function: _notes,
          params: [BigInt.from(i)]);
      if (temp[1] != "") {
        notes.add(
          Note(
            id: (temp[0] as BigInt).toInt(),
            title: temp[1],
            description: temp[2],
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<void> addNote(String title, String description) async {
    await web3client.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _createNote,
        parameters: [title, description],
      ),
    ).catchError((e){
      print("ERRORR"+e);
    });
    fetchNotes();
  }


  Future<void> deleteNote(String id) async{
    await web3client.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _deleteNote,
        parameters: [BigInt.from(int.parse(id))],
      ),
    ).catchError((e){
      print("ERRORR"+e);
    });
    fetchNotes();
  }

  Future<void> updateNote(String id,String title,String desc) async{
    await web3client.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _updateNote,
        parameters: [BigInt.from(int.parse(id)),title,desc],
      ),
    ).catchError(( e){
      print("ERRORR"+e.toString());
    });
    fetchNotes();
  }
}