import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../utils/firebase_test.dart';
import '../services/order_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _loadingText = '正在启动...';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // 初始化应用
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 测试Firebase连接
      setState(() {
        _loadingText = '正在连接数据库...';
      });

      bool isConnected = await FirebaseTest.testConnection();
      if (!isConnected) {
        print('Firebase连接失败，但继续启动应用');
      }

      // 初始化订单数据
      setState(() {
        _loadingText = '正在初始化订单数据...';
      });

      await OrderService.initializeSampleOrders();

      setState(() {
        _loadingText = '启动完成';
      });

      // 延迟2秒后跳转
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // 已登录，跳主页面
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
          );
        } else {
          // 未登录，跳登录页
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      print('应用初始化失败: $e');
      // 即使初始化失败也继续启动应用
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100], // 淡橙色
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/applogo.png',
                width: 180,
                height: 180,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                _loadingText,
                style: const TextStyle(fontSize: 18, color: Colors.deepOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
