import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/controllers/ai_shopping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai_shopping/domain/models/ai_shopping_session_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/confirmation_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AiSessionsScreen extends StatefulWidget {
  const AiSessionsScreen({super.key});

  @override
  State<AiSessionsScreen> createState() => _AiSessionsScreenState();
}

class _AiSessionsScreenState extends State<AiSessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiShoppingController>(context, listen: false)
          .loadAllSessions();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, int sessionId) {
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => PopScope(
          canPop: !isLoading,
          child: ConfirmationDialogWidget(
            icon: Images.warning,
            title: getTranslated('delete_chat', context) ?? 'Delete Chat',
            description: getTranslated('are_you_sure_delete_chat', context) ??
                'Are you sure you want to delete this chat? This action cannot be undone.',
            isLoading: isLoading,
            onYesPressed: () async {
              setDialogState(() => isLoading = true);
              await Provider.of<AiShoppingController>(context, listen: false)
                  .deleteSessionById(sessionId);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CustomAssetImageWidget(Images.aiAssistance, width: 28, height: 28),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              getTranslated('hexa_ai', context) ?? 'HexaAi',
              style: titleHeader.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).hintColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AiShoppingController>(
              builder: (context, controller, _) {
                if (controller.isLoadingSessions) {
                  return const _SessionListShimmer();
                }
                if (controller.allSessions.isEmpty) {
                  return const _EmptySessions();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  itemCount: controller.allSessions.length,
                  itemBuilder: (context, index) {
                    final session = controller.allSessions[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall),
                      child: _SessionCard(
                        session: session,
                        isActive: controller.session?.id == session.id,
                        onTap: () async {
                          await controller.switchToSession(session);
                          if (context.mounted) Navigator.pop(context);
                        },
                        onDelete: () =>
                            _showDeleteConfirmationDialog(context, session.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const _NewChatButton(),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final AiShoppingSessionModel session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  String _relativeTime(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 30) return '${diff.inDays}d ago';
      final months = (diff.inDays / 30).floor();
      if (months < 12) return '${months}mo ago';
      return '${(months / 12).floor()}y ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = session.title?.isNotEmpty == true
        ? session.title!
        : (getTranslated('new_conversation', context) ?? 'New conversation');
    final timeLabel = _relativeTime(session.lastActivityAt);
    final msgCount = session.messageCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor.withValues(alpha: 0.06)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(
              color: isActive
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.35)
                  : Theme.of(context).hintColor.withValues(alpha: 0.15),
              width: isActive ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeTwelve,
          ),
          child: Row(
            children: [
              _SessionAvatar(isActive: isActive),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleHeader.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (timeLabel.isNotEmpty) ...[
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            timeLabel,
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                        if (timeLabel.isNotEmpty && msgCount != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '·',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                        if (msgCount != null) ...[
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 11,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$msgCount msg',
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              _DeleteButton(onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionAvatar extends StatelessWidget {
  final bool isActive;

  const _SessionAvatar({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFF1B2E6B), Color(0xFF3A5FC1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive
            ? null
            : Theme.of(context).hintColor.withValues(alpha: 0.10),
      ),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        size: 20,
        color: isActive
            ? Colors.white
            : Theme.of(context).hintColor,
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _EmptySessions extends StatelessWidget {
  const _EmptySessions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeOverLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2E6B), Color(0xFF3A5FC1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3A5FC1).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              getTranslated('no_sessions_yet', context) ?? 'No sessions yet',
              style: titleHeader.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'Start a new chat to get personalized\nshopping assistance.',
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).hintColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeLarge,
        MediaQuery.of(context).padding.bottom + Dimensions.paddingSizeDefault,
      ),
      child: GestureDetector(
        onTap: () async {
          await Provider.of<AiShoppingController>(context, listen: false)
              .startNewSession();
          if (context.mounted) Navigator.pop(context);
        },
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B2E6B), Color(0xFF3A5FC1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3A5FC1).withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                getTranslated('new_chat', context) ?? 'New Chat',
                style: titleHeader.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionListShimmer extends StatelessWidget {
  const _SessionListShimmer();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).hintColor.withValues(alpha: 0.18);
    final highlight = Theme.of(context).hintColor.withValues(alpha: 0.06);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: _SessionCardSkeleton(),
        ),
      ),
    );
  }
}

class _SessionCardSkeleton extends StatelessWidget {
  const _SessionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeTwelve,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 13,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 11,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
