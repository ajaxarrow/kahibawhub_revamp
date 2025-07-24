import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../controllers/learning_material_controller.dart';
import '../../models/learning_material.dart';
import '../../models/material_update_request.dart';
import '../../providers/auth_provider.dart';
import '../../themes/colors.dart';

class PendingUpdatesModal extends ConsumerStatefulWidget {
  const PendingUpdatesModal({
    super.key,
    required this.material,
  });

  final LearningMaterial material;

  @override
  ConsumerState<PendingUpdatesModal> createState() => _PendingUpdatesModalState();
}

class _PendingUpdatesModalState extends ConsumerState<PendingUpdatesModal> {
  final LearningMaterialController _controller = LearningMaterialController();
  List<MaterialUpdateRequest> _pendingRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.watch(userProvider);
      final requests = await _controller.getAllUpdateRequests(user!.id!);

      // Filter requests for this specific material
      final materialRequests = requests.where((request) =>
      request.materialId == widget.material.id).toList();

      setState(() {
        _pendingRequests = materialRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showRequestDetails(MaterialUpdateRequest request) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RequestDetailsModal(
        request: request,
        onActionCompleted: () {
          Navigator.pop(context);
          _loadPendingRequests(); // Refresh the list
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Update Requests',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: PhosphorIcon(PhosphorIconsRegular.x),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.warning,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading requests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPendingRequests,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : _pendingRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.clockClockwise,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Requests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no pending update requests for this material.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingRequests.length,
              itemBuilder: (context, index) {
                final request = _pendingRequests[index];
                return _buildRequestCard(request);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(MaterialUpdateRequest request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = PhosphorIconsRegular.clockClockwise;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = PhosphorIconsRegular.checkCircle;
        break;
      case 'for revision':
        statusColor = Colors.red;
        statusIcon = PhosphorIconsRegular.warningCircle;
        break;
      case 'expired':
        statusColor = Colors.grey;
        statusIcon = PhosphorIconsRegular.clock;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = PhosphorIconsRegular.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Request by ${request.requestedByName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          statusIcon,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Updated fields preview
              if (request.updatedMaterialTitle != null)
                _buildFieldPreview('Title', request.updatedMaterialTitle!),
              if (request.updatedMaterialType != null)
                _buildFieldPreview('Type', request.updatedMaterialType!),

              const SizedBox(height: 12),

              // Time and contributors info
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.clock,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.timeRemaining,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    PhosphorIconsRegular.users,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${request.requestedTo.length} reviewers',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action indicator
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.arrowRight,
                    size: 14,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to review and take action',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldPreview(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Request Details Modal
class RequestDetailsModal extends ConsumerStatefulWidget {
  const RequestDetailsModal({
    super.key,
    required this.request,
    required this.onActionCompleted,
  });

  final MaterialUpdateRequest request;
  final VoidCallback onActionCompleted;

  @override
  ConsumerState<RequestDetailsModal> createState() => _RequestDetailsModalState();
}

class _RequestDetailsModalState extends ConsumerState<RequestDetailsModal> {
  final LearningMaterialController _controller = LearningMaterialController();
  final TextEditingController _rejectReasonController = TextEditingController();
  UpdateRequestPreview? _preview;
  bool _isLoadingPreview = false;
  bool _isPerformingAction = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _isLoadingPreview = true;
    });

    try {
      final user = ref.watch(userProvider);
      final preview = await _controller.reviewMaterialUpdate(
        user!.id!,
        widget.request.materialId,
      );

      setState(() {
        _preview = preview;
        _isLoadingPreview = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPreview = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preview: $e')),
        );
      }
    }
  }

  Future<void> _acceptRequest() async {
    setState(() {
      _isPerformingAction = true;
    });

    try {
      final user = ref.watch(userProvider);
      final result = await _controller.acceptUpdate(
        user!.id!,
        widget.request.materialId,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Update request accepted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onActionCompleted();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to accept update request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  Future<void> _rejectRequest() async {
    if (_rejectReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for rejection')),
      );
      return;
    }

    setState(() {
      _isPerformingAction = true;
    });

    try {
      final user = ref.watch(userProvider);
      final result = await _controller.rejectUpdate(
        user!.id!,
        widget.request.materialId,
        _rejectReasonController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Update request rejected successfully'),
              backgroundColor: Colors.orange,
            ),
          );
          widget.onActionCompleted();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to reject update request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  Future<void> _deleteRequest() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this update request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isPerformingAction = true;
    });

    try {
      final result = await _controller.deleteUpdateRequest(widget.request.materialId);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Update request deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onActionCompleted();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete update request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Update Request Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: PhosphorIcon(PhosphorIconsRegular.x),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoadingPreview
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request Info
                  _buildInfoSection(),
                  const SizedBox(height: 24),

                  // Changes Preview
                  if (_preview != null) _buildChangesPreview(),
                  const SizedBox(height: 24),

                  // Contributors Status
                  _buildContributorsStatus(),
                  const SizedBox(height: 24),

                  // Rejection Reason Input (if needed)
                  if (widget.request.status.toLowerCase() == 'pending')
                    _buildRejectReasonInput(),
                ],
              ),
            ),
          ),

          // Action Buttons (Fixed at Bottom)
          if (widget.request.status.toLowerCase() == 'pending')
            _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.info, color: primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Request Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Requested by', widget.request.requestedByName),
            _buildInfoRow('Status', widget.request.status.toUpperCase()),
            _buildInfoRow('Time Remaining', widget.request.timeRemaining),
            _buildInfoRow('Material', widget.request.materialTitle),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangesPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.gitDiff, color: primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Proposed Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_preview!.updatedTitle.isNotEmpty)
              _buildChangeRow('Title', _preview!.updatedTitle),
            if (_preview!.updatedDescription.isNotEmpty)
              _buildChangeRow('Description', _preview!.updatedDescription),
            if (_preview!.updatedType.isNotEmpty)
              _buildChangeRow('Type', _preview!.updatedType),
            if (_preview!.updatedTechnicalType.isNotEmpty)
              _buildChangeRow('Technical Type', _preview!.updatedTechnicalType),
            if (_preview!.updatedTargetAudience.isNotEmpty)
              _buildChangeRow('Target Audience', _preview!.updatedTargetAudience.join(', ')),
            if (_preview!.updatedDisciplines.isNotEmpty)
              _buildChangeRow('Disciplines', _preview!.updatedDisciplines.join(', ')),
            if (_preview!.fileBase64 != null)
              _buildChangeRow('File', 'New file uploaded'),
            if (_preview!.imageBase64 != null)
              _buildChangeRow('Image', 'New image uploaded'),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeRow(String field, String newValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              newValue,
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorsStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.users, color: primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Reviewer Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.request.requestedTo.map((contributor) =>
                _buildContributorStatusRow(contributor)),
          ],
        ),
      ),
    );
  }

  Widget _buildContributorStatusRow(ContributorResponse contributor) {
    Color statusColor;
    IconData statusIcon;

    switch (contributor.authorAction.toLowerCase()) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = PhosphorIconsRegular.checkCircle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = PhosphorIconsRegular.xCircle;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = PhosphorIconsRegular.clockClockwise;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          PhosphorIcon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contributor.authorName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (contributor.rejectReason != null)
                  Text(
                    'Reason: ${contributor.rejectReason}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            contributor.authorAction.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectReasonInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.chatCircle, color: primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Rejection Reason (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rejectReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Provide feedback for the contributor...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reject Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isPerformingAction ? null : _rejectRequest,
              icon: _isPerformingAction
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : PhosphorIcon(PhosphorIconsRegular.xCircle, size: 18),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.red.shade200),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Accept Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isPerformingAction ? null : _acceptRequest,
              icon: _isPerformingAction
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : PhosphorIcon(PhosphorIconsRegular.checkCircle, size: 18, color: Colors.white),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Delete Button (Icon only)
          IconButton(
            onPressed: _isPerformingAction ? null : _deleteRequest,
            icon: PhosphorIcon(
              PhosphorIconsRegular.trash,
              color: Colors.red.shade600,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}