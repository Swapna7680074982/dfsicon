import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/water_droplets_background.dart';

class ExhibitorDetailsScreen extends StatelessWidget {
  final Exhibitor exhibitor;

  const ExhibitorDetailsScreen({super.key, required this.exhibitor});

  @override
  Widget build(BuildContext context) {
    return WaterDropletsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            exhibitor.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tileBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: exhibitor.logoUrl != null ? Colors.white : exhibitor.bg,
                      shape: BoxShape.circle,
                      border: exhibitor.logoUrl != null ? Border.all(color: AppColors.tileBorder, width: 1) : null,
                    ),
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    child: exhibitor.logoUrl != null
                        ? Image.network(
                            exhibitor.logoUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Text(
                              exhibitor.initials.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              exhibitor.initials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exhibitor.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exhibitor.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEECF9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${exhibitor.boothCode.toUpperCase()}  •  ${exhibitor.boothZone.toUpperCase()}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (exhibitor.description.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(240),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.tileBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibitor.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (exhibitor.products.isNotEmpty || (exhibitor.brochureUrl != null && exhibitor.brochureUrl!.isNotEmpty)) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(240),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.tileBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exhibitor.products.isNotEmpty) ...[
                      const Text(
                        'PRODUCTS & SERVICES',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...exhibitor.products.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (exhibitor.brochureUrl != null && exhibitor.brochureUrl!.isNotEmpty) ...[
                      if (exhibitor.products.isNotEmpty) const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final String? url = exhibitor.brochureUrl;
                            if (url != null && url.isNotEmpty) {
                              final Uri uri = Uri.parse(url);
                              try {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to open brochure: $e'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text(
                            'DOWNLOAD BROCHURE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: Color(0xFFD1CBEF), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Consumer<ExploreProvider>(
              builder: (context, expProvider, child) {
                final booths = expProvider.summitBooths.isNotEmpty
                    ? expProvider.summitBooths
                    : (exhibitor.booths.isNotEmpty
                        ? exhibitor.booths
                        : [
                            BoothItem(
                              boothId: '1',
                              boothNumber: exhibitor.boothCode,
                              boothLabel: exhibitor.boothZone,
                              boothCapacity: '0',
                              companyName: exhibitor.name,
                              logo: exhibitor.logoUrl,
                              isOccupied: true,
                            ),
                          ]);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(240),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.tileBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BOOTH LOCATION & BLUEPRINT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Convention Center / ${exhibitor.boothCode}'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
                          final isCurrentExhibitor = (b.sponsorId != null && b.sponsorId == exhibitor.id) ||
                              (b.companyName != null && b.companyName!.toLowerCase() == exhibitor.name.toLowerCase()) ||
                              exhibitor.boothCode.toLowerCase().contains(b.boothNumber.toLowerCase());

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
                                        b.boothNumber.isNotEmpty ? b.boothNumber : b.boothLabel,
                                        style: TextStyle(
                                          fontSize: 12,
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
                                  b.boothLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCurrentExhibitor ? const Color(0xFF4338CA) : AppColors.textSecondary,
                                    fontWeight: isCurrentExhibitor ? FontWeight.w600 : FontWeight.normal,
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
            ),
            if (exhibitor.website.isNotEmpty || exhibitor.email.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(240),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.tileBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONTACT',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (exhibitor.website.isNotEmpty)
                      _buildContactRow(
                        icon: Icons.language,
                        text: exhibitor.website,
                      ),
                    if (exhibitor.website.isNotEmpty && exhibitor.email.isNotEmpty)
                      const SizedBox(height: 14),
                    if (exhibitor.email.isNotEmpty)
                      _buildContactRow(
                        icon: Icons.email_outlined,
                        text: exhibitor.email,
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),);
  }

  Widget _buildContactRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.textSecondary, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}


