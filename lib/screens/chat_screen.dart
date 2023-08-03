import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _controller = TextEditingController();
  // Create a list
  final List<ChatMessage> _message = [];
  
  // Replace with Your API-KEY
  String apiKey = "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";
  Future<void> _sendMessage() async {

    ChatMessage message = ChatMessage(text: _controller.text, sender: "U");

    setState(() {
      _message.insert(0, message);
    });

    _controller.clear();

    final response = await generateText(message.text);
    log(response.toString(), name: "botresponse");

    ChatMessage botMessage =
        ChatMessage(text: response.toString(), sender: "AI");

    setState(() {
      _message.insert(0, botMessage);
    });
  }

  Future<String> generateText(String prompt) async {

    try {
      Map<String, dynamic> requestBody = {
        "model": "text-davinci-003",
        "prompt": prompt,
        "temperature": 0,
        "max_tokens": 100,
      };

      var url = Uri.parse('https://api.openai.com/v1/completions');

      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiKey"
          },
          body: json.encode(requestBody)); // post call

      // if status code is 200 then Api Call is Successfully Executed
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return responseJson["choices"][0]["text"];
      } else {
        return "Failed to generate text: ${response.body}";
      }
    } catch (e) {
      return "Failed to generate text: $e";
    }
  }

  //  This method is used for making bottom user input text-field and and send icon part
  Widget _buidTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration:
                const InputDecoration.collapsed(hintText: "Send a message"),
          ),
        ),
        IconButton(
            onPressed: () {
              _sendMessage();
            },
            icon: const Icon(Icons.send))
      ],
    ).px12();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ChatGPT App"),
      ),
      // body
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              padding: Vx.m8,
              reverse: true,
              itemBuilder: (context, index) {
                return _message[index];
              },
              itemCount: _message.length,
            )),
            const Divider(
              height: 1,
            ),
            Container(
              decoration: const BoxDecoration(),
              child: _buidTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
