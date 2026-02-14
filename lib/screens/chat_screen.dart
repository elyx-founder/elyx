import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/haptic_service.dart';
import '../theme/level_theme.dart';
import '../services/user_progress_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  final bool isSystemAlert; // New: For system messages like "Coins Earned"
  Message(this.text, this.isUser, {this.isSystemAlert = false});
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AIService ai = AIService();

  bool loading = false;
  bool isAnalyzing = false; // For camera scanning effect

  final List<Message> messages = [
    Message("Elyx online. Drop mission.", false),
  ];

  /// VISUAL TASK ANALYSIS (Simulated Camera)
  Future<void> analyzeVisualTask(Color themeColor, UserProgressController progress) async {
    if (loading || isAnalyzing) return;

    HapticService.heavy();

    // 1. Show analyzing state
    setState(() {
      isAnalyzing = true;
      messages.add(Message("INITIALIZING VISUAL SCAN...", false, isSystemAlert: true));
    });
    scrollDown();

    // 2. Mock Analysis Delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 3. Success State
    HapticService.vibrate(); // Success vibration
    progress.addCoins(50); // REWARD

    setState(() {
      isAnalyzing = false;
      messages.add(Message("VISUAL CONFIRMED: TASK COMPLETE.", false, isSystemAlert: true));
      messages.add(Message("+50 ELITE COINS ADDED TO ACCOUNT.", false, isSystemAlert: true));
    });
    scrollDown();
  }

  /// SEND TEXT MESSAGE
  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || loading || isAnalyzing) return;

    HapticService.light();

    setState(() {
      messages.add(Message(text, true));
      loading = true;
      controller.clear();
    });

    scrollDown();

    // Mock response or real AI
    final reply = await ai.getReply(text);

    if (!mounted) return;

    HapticService.medium();

    setState(() {
      messages.add(Message(reply, false));
      loading = false;
    });

    scrollDown();
  }

  void scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Widget _buildMessageBubble(Message m, Color color) {
    // SYSTEM ALERT STYLE
    if (m.isSystemAlert) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            m.text,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5
            ),
          ),
        ),
      );
    }

    // STANDARD CHAT BUBBLES
    final bool isUser = m.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6), // Dark background for contrast
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(24),
          ),
          border: Border.all(
            color: isUser ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUser ? color.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 1,
            )
          ],
        ),
        child: Text(
          m.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access theme for dynamic color
    final theme = ElyxTheme.current(context);
    final Color themeColor = theme.color;
    final progress = Provider.of<UserProgressController>(context, listen: false);

    return Column(
      children: [

        // Spacer to push chat below header (Mentor Name/System Orb)
        const SizedBox(height: 110),

        /// CHAT LIST
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                stops: const [0.0, 0.05, 0.95, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              itemCount: messages.length + (loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i < messages.length) {
                  return _buildMessageBubble(messages[i], themeColor);
                }

                /// typing indicator
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, top: 10),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: themeColor.withValues(alpha: 0.7)
                            )
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "PROCESSING...",
                          style: TextStyle(
                              color: themeColor.withValues(alpha: 0.7),
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        /// INPUT BAR - REDESIGNED
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110), // Bottom padding adjusted to clear Dock
          child: Row(
            children: [

              // 1. MIC BUTTON (Voice Input)
              GestureDetector(
                onTap: () {
                  HapticService.selection();
                  // TODO: Hook up Voice Service
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.6),
                      border: Border.all(color: themeColor.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 10)
                      ]
                  ),
                  child: Icon(Icons.mic_none_rounded, color: themeColor, size: 22),
                ),
              ),

              const SizedBox(width: 10),

              // 2. MAIN INPUT PILL (Text + Camera)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7), // Semi-transparent dark
                      borderRadius: BorderRadius.circular(40), // Pill shape
                      border: Border.all(
                          color: themeColor.withValues(alpha: 0.8), // Theme colored border
                          width: 1.5
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.25), // Theme colored glow
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]
                  ),
                  child: Row(
                    children: [
                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          cursorColor: themeColor,
                          decoration: const InputDecoration(
                            hintText: "Command...",
                            hintStyle: TextStyle(
                                color: Colors.white60,
                                fontSize: 16,
                                letterSpacing: 1
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => sendMessage(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Camera Icon (Visual Analysis)
                      GestureDetector(
                        onTap: () => analyzeVisualTask(themeColor, progress),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle
                          ),
                          child: Icon(
                              Icons.camera_alt_outlined,
                              color: isAnalyzing ? Colors.white30 : Colors.white70,
                              size: 20
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 3. SEND BUTTON
              GestureDetector(
                onTap: sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeColor.withValues(alpha: 0.2),
                    border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                  ),
                  child: Icon(Icons.send_rounded, color: themeColor, size: 22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
