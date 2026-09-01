import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/water_droplets_background.dart';

class ExhibitorDetailsScreen extends StatelessWidget {
  final Exhibitor exhibitor;

  const ExhibitorDetailsScreen({super.key, required this.exhibitor});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    if (urlString.trim().isEmpty) return;

    String formattedUrl = urlString.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://') &&
        !formattedUrl.startsWith('mailto:')) {
      if (formattedUrl.contains('@')) {
        formattedUrl = 'mailto:$formattedUrl';
      } else {
        formattedUrl = 'https://$formattedUrl';
      }
    }

    final Uri uri = Uri.parse(formattedUrl);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $urlString'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('$label copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            exhibitor.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Profile Header Card
              _buildHeroHeaderCard(context),

              // Booth Location Highlights Card
              if (exhibitor.boothCode.trim().isNotEmpty || exhibitor.boothZone.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildBoothLocationCard(context),
              ],

              // About Description Card
              if (exhibitor.description.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildAboutCard(context),
              ],

              // Products & Services Card
              if (exhibitor.products.isNotEmpty || (exhibitor.brochureUrl != null && exhibitor.brochureUrl!.isNotEmpty)) ...[
                const SizedBox(height: 20),
                _buildProductsAndBrochureCard(context),
              ],

              // Floor Plan / Booth Blueprint Grid
              const SizedBox(height: 20),
              _buildBoothBlueprintCard(context),

              // Contact & Online Channels Card
              if (exhibitor.website.isNotEmpty || exhibitor.email.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildContactCard(context),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- HERO HEADER CARD ---
  Widget _buildHeroHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.tileBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Accent Banner Layer - Pure Blue Gradient
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xFF1D4ED8),
                  Color(0xFF0B1E36),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(25),
                    ),
                  ),
                ),
                Positioned(
                  left: 30,
                  bottom: -15,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Overlapping Top Banner
          Transform.translate(
            offset: const Offset(0, -42),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Logo Circle with double border & glow
                  Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: exhibitor.logoUrl != null ? Colors.white : exhibitor.bg,
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: exhibitor.logoUrl != null && exhibitor.logoUrl!.isNotEmpty
                          ? Image.network(
                              exhibitor.logoUrl!,
                              width: 76,
                              height: 76,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Text(
                                exhibitor.initials.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              exhibitor.initials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Exhibitor Name
                  Text(
                    exhibitor.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category Pill Badge
                  if (exhibitor.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.primary.withAlpha(45), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.category_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            exhibitor.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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

  // --- BOOTH LOCATION CARD ---
  Widget _buildBoothLocationCard(BuildContext context) {
    final boothText = exhibitor.boothCode.trim().toUpperCase();
    final zoneText = exhibitor.boothZone.trim().toUpperCase();
    final displayText = boothText.isNotEmpty && zoneText.isNotEmpty
        ? '$boothText  •  $zoneText'
        : (boothText.isNotEmpty ? boothText : zoneText);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEECF9), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withAlpha(38), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(76),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'BOOTH LOCATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, displayText, 'Booth info'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(178),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'COPY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ABOUT CARD ---
  Widget _buildAboutCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.tileBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.business_rounded,
            title: 'ABOUT EXHIBITOR',
          ),
          const SizedBox(height: 14),
          Text(
            exhibitor.description,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textPrimary,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  // --- PRODUCTS & BROCHURE CARD ---
  Widget _buildProductsAndBrochureCard(BuildContext context) {
    final hasBrochure = exhibitor.brochureUrl != null && exhibitor.brochureUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.tileBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.inventory_2_rounded,
            title: 'PRODUCTS & SERVICES',
          ),
          const SizedBox(height: 16),

          if (exhibitor.products.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: exhibitor.products.map((p) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          p,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          if (hasBrochure) ...[
            if (exhibitor.products.isNotEmpty) const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(12),
                    const Color(0xFF6366F1).withAlpha(20),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withAlpha(30), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Company Brochure',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Download full catalog & presentation PDF',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _launchUrl(context, exhibitor.brochureUrl!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.download_rounded, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Get PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- BOOTH BLUEPRINT CARD ---
  Widget _buildBoothBlueprintCard(BuildContext context) {
    return Consumer<ExploreProvider>(
      builder: (context, expProvider, child) {
        final booths = expProvider.summitBooths.isNotEmpty
            ? expProvider.summitBooths
            : exhibitor.booths;

        if (booths.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.tileBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                icon: Icons.map_rounded,
                title: 'BOOTH LOCATION & BLUEPRINT',
              ),
              if (exhibitor.boothCode.trim().isNotEmpty || exhibitor.boothZone.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Convention Center / ${exhibitor.boothZone.isNotEmpty ? (exhibitor.boothCode.isNotEmpty ? "${exhibitor.boothZone} • ${exhibitor.boothCode}" : exhibitor.boothZone) : exhibitor.boothCode}'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: booths.length,
                itemBuilder: (context, index) {
                  final b = booths[index];
                  final exhibitorBoothNumbers = exhibitor.boothCode
                      .split(',')
                      .map((e) => e.replaceAll('#', '').trim().toLowerCase())
                      .where((e) => e.isNotEmpty)
                      .toSet();

                  final exhibitorBoothLabels = exhibitor.boothZone
                      .split(',')
                      .map((e) => e.replaceAll('#', '').trim().toLowerCase())
                      .where((e) => e.isNotEmpty)
                      .toSet();

                  final isCurrentExhibitor = (b.sponsorId != null && b.sponsorId!.isNotEmpty && b.sponsorId == exhibitor.id) ||
                      (b.companyName != null && b.companyName!.trim().isNotEmpty && b.companyName!.trim().toLowerCase() == exhibitor.name.trim().toLowerCase()) ||
                      (b.boothNumber.trim().isNotEmpty && exhibitorBoothNumbers.contains(b.boothNumber.replaceAll('#', '').trim().toLowerCase())) ||
                      (b.boothLabel.trim().isNotEmpty && exhibitorBoothLabels.contains(b.boothLabel.replaceAll('#', '').trim().toLowerCase())) ||
                      exhibitor.booths.any((eb) =>
                          (eb.boothId.isNotEmpty && eb.boothId == b.boothId) ||
                          (eb.boothNumber.isNotEmpty && eb.boothNumber.trim().toLowerCase() == b.boothNumber.trim().toLowerCase()) ||
                          (eb.boothLabel.isNotEmpty && eb.boothLabel.trim().toLowerCase() == b.boothLabel.trim().toLowerCase()));

                  final logoPath = (b.logo != null && b.logo!.isNotEmpty) ? b.logo : (isCurrentExhibitor ? exhibitor.logoUrl : null);

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCurrentExhibitor ? const Color(0xFFEEF2FF) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrentExhibitor ? const Color(0xFF6366F1) : Colors.grey.shade300,
                        width: isCurrentExhibitor ? 2 : 1,
                      ),
                      boxShadow: isCurrentExhibitor
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withAlpha(38),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (logoPath != null && logoPath.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  logoPath,
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Icon(
                                    Icons.storefront_rounded,
                                    size: 18,
                                    color: isCurrentExhibitor ? const Color(0xFF6366F1) : AppColors.primary,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.storefront_rounded,
                                size: 18,
                                color: isCurrentExhibitor ? const Color(0xFF6366F1) : AppColors.textLight,
                              ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                b.boothLabel.isNotEmpty ? b.boothLabel : b.boothNumber,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentExhibitor ? const Color(0xFF1E1B4B) : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.boothNumber.isNotEmpty ? b.boothNumber : b.boothLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: isCurrentExhibitor ? const Color(0xFF4338CA) : AppColors.textSecondary,
                            fontWeight: isCurrentExhibitor ? FontWeight.w700 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (b.companyName != null && b.companyName!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            b.companyName!,
                            style: TextStyle(
                              fontSize: 10,
                              color: isCurrentExhibitor ? const Color(0xFF6366F1) : AppColors.textLight,
                              fontWeight: isCurrentExhibitor ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- CONTACT CARD ---
  Widget _buildContactCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.tileBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.connect_without_contact_rounded,
            title: 'GET IN TOUCH',
          ),
          const SizedBox(height: 16),
          if (exhibitor.website.isNotEmpty)
            _buildContactRow(
              context,
              icon: Icons.language_rounded,
              title: 'Official Website',
              text: exhibitor.website,
              onTap: () => _launchUrl(context, exhibitor.website),
              onCopy: () => _copyToClipboard(context, exhibitor.website, 'Website URL'),
            ),
          if (exhibitor.website.isNotEmpty && exhibitor.email.isNotEmpty)
            const SizedBox(height: 14),
          if (exhibitor.email.isNotEmpty)
            _buildContactRow(
              context,
              icon: Icons.email_rounded,
              title: 'Email Address',
              text: exhibitor.email,
              onTap: () => _launchUrl(context, 'mailto:${exhibitor.email}'),
              onCopy: () => _copyToClipboard(context, exhibitor.email, 'Email address'),
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
            onPressed: onCopy,
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }

  // --- SECTION HEADER HELPER ---
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
