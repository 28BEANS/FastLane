import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, text);
    });
    _textController.clear();
  }

  Widget _buildMessage(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: const Color(0xFFC3C3C3),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(text),
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column (children: [
        Container(
          width: double.infinity,
          height: 190,
          color: Colors.blue,
          padding: const EdgeInsets.only(left: 40),
          clipBehavior: Clip.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, 50),
                child: const Text(
                'Juan de la Cruz',
                style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              SizedBox(height: 5),
              Transform.translate(
                offset: Offset(0, 40),
                child: Text(
                  'juandelacruz@email.com',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 5),
              Transform.translate(
                offset: Offset(30, 40),
                child: Text(
                  'Unemployed',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(8.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessage(_messages[index]);
            }
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: TextFormField(
            controller: _textController,
            onFieldSubmitted: _handleSubmitted,
            decoration: InputDecoration(
              hintText: 'Press here to talk with BINO',
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 50),
              filled: true,
              fillColor: const Color(0xFFF4F4F4),

              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),

              border: const OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                borderSide:BorderSide(
                  color: Color(0xFF919191),
                  width: 2.0,
              ),
            ),
          ),
        ),
      ),
    ],
    )
    );
  }
}
