import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/coach_video.dart';
import '../../data/repositories/ask_alpha_repository.dart';

class MessageAttachment extends ConsumerWidget {
  final String body;
  const MessageAttachment({super.key, required this.body});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, dynamic>? attachment;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map &&
          decoded['type'] == 'attachment' &&
          decoded['bucket'] == 'message-attachments') {
        attachment = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    if (attachment == null) return Text(body);
    return _PrivateMedia(attachment: attachment);
  }
}

class _PrivateMedia extends ConsumerStatefulWidget {
  final Map<String, dynamic> attachment;
  const _PrivateMedia({required this.attachment});
  @override
  ConsumerState<_PrivateMedia> createState() => _PrivateMediaState();
}

class _PrivateMediaState extends ConsumerState<_PrivateMedia> {
  late Future<String> url = ref
      .read(askAlphaRepositoryProvider)
      .attachmentUrl('${widget.attachment['path']}');
  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: url,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return TextButton(
          onPressed: () => setState(
            () => url = ref
                .read(askAlphaRepositoryProvider)
                .attachmentUrl('${widget.attachment['path']}'),
          ),
          child: const Text('Unable to load attachment. Retry'),
        );
      }
      if (!snapshot.hasData) return const CircularProgressIndicator();
      final type = widget.attachment['media'];
      if (type == 'image') {
        return Image.network(
          snapshot.data!,
          errorBuilder: (_, e, stack) => const Text('Unable to display image.'),
        );
      }
      if (type == 'video') return CoachVideo(url: snapshot.data!);
      return TextButton.icon(
        onPressed: () => launchUrl(Uri.parse(snapshot.data!)),
        icon: const Icon(Icons.audiotrack),
        label: Text('${widget.attachment['name'] ?? 'Voice message'}'),
      );
    },
  );
}

Future<void> pickMessageAttachment(
  BuildContext context,
  Future<void> Function(PlatformFile, String) send,
) async {
  final type = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in [
            ('image', Icons.image_outlined, 'Image'),
            ('video', Icons.videocam_outlined, 'Video'),
            ('audio', Icons.mic_none, 'Audio / voice recording'),
          ])
            ListTile(
              leading: Icon(item.$2),
              title: Text(item.$3),
              onTap: () => Navigator.pop(context, item.$1),
            ),
        ],
      ),
    ),
  );
  if (type == null) return;
  final files = await FilePicker.pickFiles(
    type: type == 'image'
        ? FileType.image
        : type == 'video'
        ? FileType.video
        : FileType.audio,
    withData: true,
  );
  if (files == null) return;
  await send(files.files.single, type);
}
