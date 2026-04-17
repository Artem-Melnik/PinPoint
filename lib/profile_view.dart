import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/models.dart';

class ProfileView extends StatelessWidget {
  final AppUser user;
  final bool isPlatformAdmin;
  final int savedEventsCount;
  final int followedOrganizationsCount;

  const ProfileView({
    super.key,
    required this.user,
    required this.isPlatformAdmin,
    required this.savedEventsCount,
    required this.followedOrganizationsCount,
  });

  // Formats a date to a readable string
  String _formatMemberSince(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Formats a date to a readable string
  String _formatLastUpdated(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  // Formats a role to a readable string
  String _formatRole(AppRole role) {
    final raw = role.name;
    return raw.isEmpty
        ? 'User'
        : raw[0].toUpperCase() + raw.substring(1);
  }

  @override
  // Builds the profile view
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 16),
          _buildStatsRow(context),
          const SizedBox(height: 16),
          _buildAccountInfoCard(context),
        ],
      ),
    );
  }

  // Builds a card with user info
  Widget _buildHeaderCard(BuildContext context) {
    final hasImage =
        user.profileImageUrl != null && user.profileImageUrl!.trim().isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage:
                hasImage ? NetworkImage(user.profileImageUrl!) : null,
              child: !hasImage
                  ? Text(
                    user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.badge_outlined, size: 18),
                        label: Text(_formatRole(user.role)),
                      ),
                      Chip(
                        avatar: const Icon(Icons.calendar_today_outlined, size:16),
                        label: Text('Member since ${_formatMemberSince(user.createdAt)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                      (user.bio != null && user.bio!.trim().isNotEmpty)
                          ? user.bio!
                          : 'No bio added yet',
                      style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profile (WIP)'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a row of stats cards
  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Saved',
            value: savedEventsCount.toString(),
            icon: Icons.bookmark_border,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Following',
            value: followedOrganizationsCount.toString(),
            icon: Icons.favorite_border,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            label: 'Memberships',
            value: user.memberOrganizationIds.length.toString(),
            icon: Icons.groups_outlined,
          ),
        ),
      ],
    );
  }

  // Builds a stat card
  Widget _buildStatCard(
      BuildContext context, {
      required String label,
      required String value,
      required IconData icon,
    }) {
    return Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
    );
  }

  // Builds a card with account info
  Widget _buildAccountInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _buildInfoRow(
              icon: Icons.person_outlined,
              label: 'User ID',
              value: user.id,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.shield,
              label: 'Role',
              value: _formatRole(user.role),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.update_outlined,
              label: 'Last Updated',
              value: _formatLastUpdated(user.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a row of info
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}