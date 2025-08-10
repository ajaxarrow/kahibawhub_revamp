import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahibawhub_revamp/controllers/app_user_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import '../models/learning_material.dart';
import '../controllers/learning_material_controller.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../screens/material_details/material_details_overview_screen.dart';
import '../themes/colors.dart';
import '../utils/base64_image_utils.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/materials/material_dialog_form.dart';
import '../widgets/materials/material_update_request_dialog.dart';
import '../widgets/materials/pending_updates_modal.dart';

class MaterialDetailsLayout extends ConsumerStatefulWidget {
  const MaterialDetailsLayout({super.key, required this.material});

  final LearningMaterial material;

  @override
  ConsumerState<MaterialDetailsLayout> createState() => _MaterialDetailsLayoutState();
}

class _MaterialDetailsLayoutState extends ConsumerState<MaterialDetailsLayout> {
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _isPreviewing = false;
  int _selectedIndex = 0;
  LearningMaterial? _completeMaterial;
  final LearningMaterialController _controller = LearningMaterialController();

  final List<String> _tabTitles = [
    "Overview",
    "Comments",
    "Reviews",
  ];

  List<Widget> _tabScreens = [];

  @override
  void initState() {
    super.initState();
    _fetchCompleteMaterialData();
  }

  Future<void> _fetchCompleteMaterialData() async {
    try {
      final user = ref.read(userProvider);

      if (user?.id == null || widget.material.id == null) {
        setState(() {
          _isLoading = false;
          _completeMaterial = widget.material;
        });
        return;
      }

      final completeMaterial = await _controller.fetchLearningMaterialByID(
        userID: user!.id!,
        materialID: widget.material.id.toString(),
      );

      // Preserve original image if needed
      if (widget.material.image != null) {
        completeMaterial.image = widget.material.image;
      }

      // Set edit access
      if (user.id == completeMaterial.authorData?.id) {
        completeMaterial.canEdit = true;
      }

      // Update UI
      setState(() {
        _completeMaterial = completeMaterial;
        _isLoading = false;
        _tabScreens = [
          MaterialDetailsOverviewScreen(material: completeMaterial),
          _buildCommentsTab(),
          _buildReviewsTab(),
        ];
      });
    } catch (e) {
      print('Error fetching complete material data: $e');
      setState(() {
        _isLoading = false;
        _completeMaterial = widget.material;
        _tabScreens = [
          MaterialDetailsOverviewScreen(material: widget.material),
          _buildCommentsTab(),
          _buildReviewsTab(),
        ];
      });
    }
  }

  Widget _buildCommentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(PhosphorIconsRegular.chatCircle, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Comments feature coming soon',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(PhosphorIconsRegular.star, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Reviews feature coming soon',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showCollaborationRequestsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Collaboration Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const PhosphorIcon(PhosphorIconsRegular.x),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _controller.getMyCollaborationRequests(
                    userId: ref.read(userProvider)!.id!,
                    materialId: widget.material.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading collaboration requests...'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const PhosphorIcon(PhosphorIconsRegular.warning, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error: ${snapshot.error}'),
                          ],
                        ),
                      );
                    }

                    final requests = snapshot.data ?? [];

                    if (requests.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PhosphorIcon(PhosphorIconsRegular.users, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No collaboration requests sent',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _buildCollaborationRequestItem(request);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollaborationRequestItem(Map<String, dynamic> request) {
    final requestedTo = List<Map<String, dynamic>>.from(request['requestedTo']);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request['materialTitle'] ?? 'Unknown Material',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Request ID: ${request['collabRequestId']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Requested Authors:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...requestedTo.map((author) => _buildAuthorRequestItem(author)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRequestItem(Map<String, dynamic> author) {
    final authorId = author['authorId'];
    final status = author['authorAction'] ?? 'pending';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<UserProfile>(
              future: AppUserController().getUserProfile(userID: authorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading author...'),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Text('Error loading author: $authorId');
                }

                final userProfile = snapshot.data;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        (userProfile?.firstName?.isNotEmpty == true || userProfile?.lastName?.isNotEmpty == true)
                            ? '${userProfile?.firstName?[0] ?? ''}${userProfile?.lastName?[0] ?? ''}'.toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        [
                          userProfile?.firstName,
                          userProfile?.lastName
                        ].where((s) => s?.isNotEmpty == true).join(' ')
                            .trim()
                            .isNotEmpty
                            ? '${userProfile?.firstName ?? ''} ${userProfile?.lastName ?? ''}'.trim()
                            : 'Unknown Author',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Future<void> downloadFile() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final material = _completeMaterial!;

      if (material.materialFile == null || material.materialFile!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file available for download'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Download file from URL
      final response = await http.get(Uri.parse(material.materialFile!));

      if (response.statusCode == 200) {
        // Get file extension from URL or content type
        String fileExtension = _getFileExtensionFromUrl(material.materialFile!);
        if (fileExtension.isEmpty) {
          fileExtension = _getFileExtensionFromContentType(response.headers['content-type'] ?? '');
        }

        // Save file and get the download path
        final downloadPath = await _saveFileFromBytes(
          response.bodyBytes,
          material.title ?? 'document',
          fileExtension,
        );

        if (downloadPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('File downloaded successfully'),
                  const SizedBox(height: 4),
                  Text(
                    'Path: $downloadPath',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> previewFile() async {
    setState(() {
      _isPreviewing = true;
    });

    try {
      final material = _completeMaterial!;

      if (material.materialFile == null || material.materialFile!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file available for preview'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // First, download the file to determine its type from content-type header
      final response = await http.head(Uri.parse(material.materialFile!));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';

        // Check if file type is supported for preview
        if (contentType.contains('application/pdf')) {
          _showPreviewModal(material.materialFile!, 'application/pdf');
        } else {
          // If preview not supported, automatically download
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preview not supported for this file type. Downloading instead...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          // Start download automatically
          downloadFile();
        }
      } else {
        throw Exception('Failed to check file type: ${response.statusCode}');
      }
    } catch (e) {
      print('Error previewing file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to preview file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPreviewing = false;
      });
    }
  }

  String _getFileExtensionFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      String path = uri.path;
      if (path.contains('.')) {
        return path.substring(path.lastIndexOf('.'));
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _getFileExtensionFromContentType(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'application/pdf':
        return '.pdf';
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'text/plain':
        return '.txt';
      case 'application/msword':
        return '.doc';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return '.docx';
      case 'application/vnd.ms-excel':
        return '.xls';
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return '.xlsx';
      case 'application/vnd.ms-powerpoint':
        return '.ppt';
      case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        return '.pptx';
      default:
        return '';
    }
  }

  void _showPreviewModal(String fileUrl, String mimeType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Preview: Document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const PhosphorIcon(PhosphorIconsRegular.x),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: _buildPreviewContent(fileUrl, mimeType),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent(String fileUrl, String mimeType) {
    if (mimeType == 'application/pdf') {
      return _buildPdfPreview(fileUrl);
    } else if (mimeType.contains('image/')) {
      return _buildImagePreview(fileUrl);
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(PhosphorIconsRegular.fileX, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Preview not available for this file type',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImagePreview(String imageUrl) {
    return Center(
      child: InteractiveViewer(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading image...'),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(PhosphorIconsRegular.warning, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading image'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPdfPreview(String fileUrl) {
    return FutureBuilder<File>(
      future: _downloadTempFile(fileUrl, 'pdf'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PDFView(
            filePath: snapshot.data!.path,
            swipeHorizontal: false,
            autoSpacing: true,
            pageSnap: true,
            pageFling: true,
            onError: (error) {
              print('PDF Preview Error: $error');
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(PhosphorIconsRegular.warning, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading PDF: ${snapshot.error}'),
              ],
            ),
          );
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading PDF preview...'),
              ],
            ),
          );
        }
      },
    );
  }

  Future<File> _downloadTempFile(String fileUrl, String extension) async {
    final response = await http.get(Uri.parse(fileUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to download file for preview');
    }

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_preview.$extension');
    await tempFile.writeAsBytes(response.bodyBytes);
    return tempFile;
  }

  Future<String?> _saveFileFromBytes(List<int> bytes, String fileName, String extension) async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (!permission.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return null;
        }
      }

      // Clean filename and add extension
      final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
      final finalFileName = extension.isNotEmpty
          ? '$cleanFileName$extension'
          : cleanFileName;

      // Get appropriate directory based on platform
      Directory directory;
      if (Platform.isAndroid) {
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!directory.existsSync()) {
            directory = await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Desktop platforms
        directory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      // Create file path
      final filePath = '${directory.path}/$finalFileName';
      final file = File(filePath);

      // Write bytes to file
      await file.writeAsBytes(bytes);

      print('File saved to: $filePath');
      return filePath;
    } catch (e) {
      print('Error saving file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save file: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  void openMaterialFormDialog(){
    showModalBottomSheet(
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        builder: (ctx) => MaterialDialogForm(
            mode: Mode.update,
            material: _completeMaterial,
            materialId: widget.material.id
        )
    );
  }

  void _showActionsMenu() {
    final user = ref.watch(userProvider);
    final material = _completeMaterial!;

    final isPrimaryAuthor = material.authorData?.id == user?.id;
    final isContributor = material.contributorIds?.contains(user?.id) ?? false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildActionsBottomSheet(
        isPrimaryAuthor: isPrimaryAuthor,
        isContributor: isContributor,
        material: material,
      ),
    );
  }

  Widget _buildActionsBottomSheet({
    required bool isPrimaryAuthor,
    required bool isContributor,
    required LearningMaterial material,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Material Actions ${material.primaryAuthorID}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            if (isPrimaryAuthor) ...[
              ListTile(
                leading: PhosphorIcon(PhosphorIconsRegular.pencil, color: primaryColor),
                title: const Text('Edit Material'),
                subtitle: const Text('Make direct changes to the material'),
                onTap: () {
                  Navigator.pop(context);
                  openMaterialFormDialog();
                },
              ),
              const Divider(),
            ],

            if (isContributor && !isPrimaryAuthor) ...[
              ListTile(
                leading: PhosphorIcon(PhosphorIconsRegular.gitPullRequest, color: Colors.blue),
                title: const Text('Request Update'),
                subtitle: const Text('Propose changes to the material'),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateRequestDialog();
                },
              ),
              const Divider(),
            ],

            if (isPrimaryAuthor) ...[
              ListTile(
                leading: PhosphorIcon(
                  PhosphorIconsRegular.clockClockwise,
                  color: material.hasPendingUpdates ? Colors.orange : Colors.grey,
                ),
                title: const Text('Pending Updates'),
                subtitle: Text(
                  material.hasPendingUpdates
                      ? 'Review and manage update requests'
                      : 'No pending update requests',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showPendingUpdatesModal();
                },
                trailing: material.hasPendingUpdates
                    ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : null,
              ),
              const Divider(),
            ],
            if (isPrimaryAuthor) ...[
              ListTile(
                leading: PhosphorIcon(PhosphorIconsRegular.users, color: Colors.purple),
                title: const Text('Collaboration Requests'),
                subtitle: const Text('View sent collaboration requests'),
                onTap: () {
                  Navigator.pop(context);
                  _showCollaborationRequestsModal();
                },
              ),
              const Divider(),
            ],

            ListTile(
              leading: _isPreviewing
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : PhosphorIcon(PhosphorIconsRegular.eye, color: Colors.blue),
              title: const Text('Preview / Download'),
              subtitle: const Text('Preview if supported, otherwise download'),
              onTap: _isPreviewing ? null : () {
                Navigator.pop(context);
                previewFile();
              },
            ),
            const Divider(),

            ListTile(
              leading: _isDownloading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : PhosphorIcon(PhosphorIconsRegular.download, color: Colors.green),
              title: const Text('Download'),
              subtitle: const Text('Download the material file'),
              onTap: _isDownloading ? null : () {
                Navigator.pop(context);
                downloadFile();
              },
            ),
            const Divider(),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade700,
                  elevation: 0,
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateRequestDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaterialUpdateRequestDialog(
        id: widget.material.id,
        material: _completeMaterial!,
      ),
    );
  }

  void _showPendingUpdatesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PendingUpdatesModal(
        material: widget.material,
      ),
    );
  }

  void _shareMaterial() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality not implemented yet')),
    );
  }

  void _reportMaterial() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report functionality not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const CustomAppbar(title: 'Material Details', isForMain: false),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading material details...'),
            ],
          ),
        ),
      );
    }

    final material = _completeMaterial ?? widget.material;

    return Scaffold(
      appBar: const CustomAppbar(title: 'Material Details', isForMain: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, material),
          _buildTabBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 25,
                left: 25,
                top: 10,
              ),
              child: _tabScreens.isNotEmpty ? _tabScreens[_selectedIndex] : Container(),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LearningMaterial material) {
    final user = ref.watch(userProvider);
    final isPrimaryAuthor = material.primaryAuthorID == user?.id;

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: material.image != null
              ? (material.image!.startsWith('data:image/png;base64')
              ? Image.memory(
            base64ToBytes(material.image!),
            width: MediaQuery.of(context).size.width,
            height: 170,
            fit: BoxFit.cover,
          )
              : Image.network(
            material.image!,
            width: MediaQuery.of(context).size.width,
            height: 170,
            fit: BoxFit.cover,
          ))
              : Image.asset(
            'lib/assets/images/placeholder.jpg',
            width: MediaQuery.of(context).size.width,
            height: 170,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      material.title ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  // Pending updates indicator (for primary authors)
                  if (material.hasPendingUpdates && isPrimaryAuthor) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Updates Pending',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(material),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(LearningMaterial material) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          _buildIconText(
            PhosphorIconsDuotone.eye,
            material.views.toString(),
            const Color(0xff5856D6),
          ),
          _buildSeparator(),
          _buildIconText(
            PhosphorIconsDuotone.star,
            material.ratings.toString(),
            const Color(0xffFFCC00),
          ),
        ]),
        Row(children: [
          GestureDetector(
            onTap: _showActionsMenu,
            child: _buildIcon(PhosphorIconsRegular.dotsThreeVertical),
          ),
        ]),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        PhosphorIcon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: PhosphorIcon(icon, size: 16),
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text('|'),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: 35,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 1, // Only one row
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                _tabTitles.length,
                    (index) => _buildTab(_tabTitles[index], index),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Preview Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isPreviewing ? null : () {
                previewFile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: primaryColor),
                ),
              ),
              child: _isPreviewing
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(PhosphorIconsRegular.eye, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Preview",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Download Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isDownloading ? null : () {
                downloadFile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isDownloading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(PhosphorIconsRegular.download, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Download",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}