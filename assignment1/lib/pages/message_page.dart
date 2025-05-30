import 'package:flutter/material.dart';
import 'package:assignment1/pages/contact_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        elevation: 0,
        title: const Text(
          'Message',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.purple,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'Riders'),
            Tab(text: 'Friends'),
            Tab(text: 'Merchant'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessageList(_getRidersMessages()),
          _buildMessageList(_getFriendsMessages()),
          _buildMessageList(_getMerchantMessages()),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<MessageItem> messages) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Container(
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.yellow[200],
              backgroundImage:
                  message.avatarPath != null && message.avatarPath!.isNotEmpty
                      ? AssetImage(message.avatarPath!)
                      : null,
              child:
                  message.avatarPath == null || message.avatarPath!.isEmpty
                      ? Icon(Icons.person, color: Colors.brown[600], size: 30)
                      : null,
            ),
            title: Text(
              message.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message.preview,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Text(
              message.time,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            onTap: () {
              // 点击跳转到 ContactPage，传递名字和头像路径
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ContactPage(
                        contactName: message.name,
                        contactAvatar: message.avatarPath ?? '',
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<MessageItem> _getRidersMessages() {
    return [
      MessageItem(
        name: 'James',
        preview: "Your food's here!",
        time: '11:30',
        avatarPath: 'assets/images/rider1.jpg',
      ),
      MessageItem(
        name: 'Michael',
        preview: 'Thank you !',
        time: 'yesterday',
        avatarPath: 'assets/images/rider2.jpg',
      ),
      MessageItem(
        name: 'David',
        preview: 'Your food has been delivered.',
        time: 'yesterday',
        avatarPath: 'assets/images/rider1.jpg',
      ),
      MessageItem(
        name: 'John',
        preview: '[image]',
        time: '2025/5/20',
        avatarPath: 'assets/images/rider1.jpg',
      ),
      MessageItem(
        name: 'Daniel',
        preview: 'Appreciate~',
        time: '2025/5/19',
        avatarPath: 'assets/images/rider2.jpg',
      ),
      MessageItem(
        name: 'Anna',
        preview: 'Thank you !',
        time: '2025/5/18',
        avatarPath: 'assets/images/rider3.jpg',
      ),
      MessageItem(
        name: 'Tom',
        preview: 'Order completed',
        time: '2025/5/17',
        avatarPath: 'assets/images/rider2.jpg',
      ),
      MessageItem(
        name: 'Sarah',
        preview: 'On my way!',
        time: '2025/5/16',
        avatarPath: 'assets/images/rider3.jpg',
      ),
      MessageItem(
        name: 'Mike',
        preview: 'Food delivered safely',
        time: '2025/5/15',
        avatarPath: 'assets/images/rider1.jpg',
      ),
      MessageItem(
        name: 'Lisa',
        preview: 'Thanks for the tip!',
        time: '2025/5/14',
        avatarPath: 'assets/images/rider3.jpg',
      ),
    ];
  }

  List<MessageItem> _getFriendsMessages() {
    return [
      MessageItem(
        name: 'Alice',
        preview: 'Hey! How are you?',
        time: '10:45',
        avatarPath: 'assets/images/friend1.jpg',
      ),
      MessageItem(
        name: 'Bob',
        preview: 'Want to grab lunch?',
        time: 'yesterday',
        avatarPath: 'assets/images/friend2.jpg',
      ),
      MessageItem(
        name: 'Carol',
        preview: 'Thanks for yesterday!',
        time: '2025/5/19',
        avatarPath: 'assets/images/friend3.jpg',
      ),
      MessageItem(
        name: 'Dan',
        preview: 'See you tomorrow',
        time: '2025/5/18',
        avatarPath: 'assets/images/friend4.jpg',
      ),
    ];
  }

  List<MessageItem> _getMerchantMessages() {
    return [
      MessageItem(
        name: 'McDonald',
        preview: 'Your coupon expires in one day!',
        time: '09:00',
        avatarPath: 'assets/images/mcdmerchant.jpg',
      ),
      MessageItem(
        name: 'Mixue',
        preview: 'Looking forward to your review!',
        time: 'yesterday',
        avatarPath: 'assets/images/mixuemerchant.jpg',
      ),
      MessageItem(
        name: 'Shanxi Noodles',
        preview: 'Your voucher has been updated!',
        time: '2025/5/20',
        avatarPath: 'assets/images/noodlemerchant.jpg',
      ),
    ];
  }
}

class MessageItem {
  final String name;
  final String preview;
  final String time;
  final String? avatarPath;

  MessageItem({
    required this.name,
    required this.preview,
    required this.time,
    this.avatarPath,
  });
}
