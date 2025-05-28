import 'package:flutter/material.dart';

class BannerPanel extends StatelessWidget {
  final String imagePath;
  final String description;
  final VoidCallback onClose;

  const BannerPanel({
    super.key,
    required this.imagePath,
    required this.description,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        elevation: 12,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 420,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // 顶部大图
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // 描述文字
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),

              // 关闭按钮
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: onClose,
                  child: const Text('Close', style: TextStyle(color: Colors.orange)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
