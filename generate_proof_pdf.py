#!/usr/bin/env python3
"""Generate a professional Deployment Proof PDF for college submission."""

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.colors import HexColor
from reportlab.lib.units import inch, mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    HRFlowable, KeepTogether
)
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
import os

# Colors matching the app palette
BONE_WHITE = HexColor('#F9F6F0')
SOFT_CHARCOAL = HexColor('#2C2C2C')
MUTED_MUSTARD = HexColor('#DCAE1D')
BRICK_RED = HexColor('#B24C38')
LIGHT_GRAY = HexColor('#F0F0F0')
WHITE = colors.white

output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'DEPLOYMENT_PROOF.pdf')

doc = SimpleDocTemplate(
    output_path,
    pagesize=A4,
    topMargin=0.75*inch,
    bottomMargin=0.75*inch,
    leftMargin=0.75*inch,
    rightMargin=0.75*inch,
)

styles = getSampleStyleSheet()

# Custom styles
styles.add(ParagraphStyle(
    'DocTitle', parent=styles['Title'],
    fontSize=22, textColor=SOFT_CHARCOAL,
    spaceAfter=6, alignment=TA_CENTER,
    fontName='Helvetica-Bold'
))
styles.add(ParagraphStyle(
    'DocSubtitle', parent=styles['Normal'],
    fontSize=11, textColor=HexColor('#666666'),
    alignment=TA_CENTER, spaceAfter=20
))
styles.add(ParagraphStyle(
    'SectionHead', parent=styles['Heading2'],
    fontSize=14, textColor=WHITE,
    fontName='Helvetica-Bold', spaceAfter=10, spaceBefore=16,
    backColor=SOFT_CHARCOAL, borderPadding=(8, 8, 8, 8),
    leftIndent=0, rightIndent=0
))
styles.add(ParagraphStyle(
    'BodyText2', parent=styles['Normal'],
    fontSize=10, textColor=SOFT_CHARCOAL,
    spaceAfter=6, leading=14
))
styles.add(ParagraphStyle(
    'CommitStyle', parent=styles['Code'],
    fontSize=8, textColor=HexColor('#333333'),
    backColor=LIGHT_GRAY, borderPadding=6,
    spaceAfter=2, leading=12
))

story = []

# ── Title Block ──
story.append(Spacer(1, 20))
story.append(Paragraph("IT CLUB Application", styles['DocTitle']))
story.append(Paragraph("Deployment Proof & Technical Report", styles['DocSubtitle']))
story.append(Spacer(1, 4))

# Accent line
story.append(HRFlowable(width="60%", thickness=3, color=MUTED_MUSTARD, spaceAfter=8, spaceBefore=0))

# Meta info
meta_data = [
    ['Developer', 'Mahalakshmi & Team'],
    ['Date of Deployment', '14 April 2026'],
    ['Version', 'v1.0.0'],
    ['Package Name', 'com.itclub.college_club_app'],
]
meta_table = Table(meta_data, colWidths=[2*inch, 4*inch])
meta_table.setStyle(TableStyle([
    ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, -1), 10),
    ('TEXTCOLOR', (0, 0), (-1, -1), SOFT_CHARCOAL),
    ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
    ('ALIGN', (1, 0), (1, -1), 'LEFT'),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ('TOPPADDING', (0, 0), (-1, -1), 4),
    ('RIGHTPADDING', (0, 0), (0, -1), 12),
]))
story.append(meta_table)
story.append(Spacer(1, 16))

# ── Helper for section tables ──
def make_table(data, col_widths=None):
    if col_widths is None:
        col_widths = [2.2*inch, 4.3*inch]
    t = Table(data, colWidths=col_widths)
    t.setStyle(TableStyle([
        # Header row
        ('BACKGROUND', (0, 0), (-1, 0), SOFT_CHARCOAL),
        ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        # Body rows
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 1), (-1, -1), 9),
        ('TEXTCOLOR', (0, 1), (-1, -1), SOFT_CHARCOAL),
        ('BACKGROUND', (0, 1), (-1, -1), BONE_WHITE),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [BONE_WHITE, WHITE]),
        # Grid
        ('GRID', (0, 0), (-1, -1), 0.5, HexColor('#DDDDDD')),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    return t

# ── Section 1: Deployment Summary ──
story.append(Paragraph("1. Deployment Summary", styles['SectionHead']))
summary_data = [
    ['Field', 'Details'],
    ['Application Name', 'IT CLUB (Cyber Nauts)'],
    ['Platform', 'Android (Flutter)'],
    ['APK Size', '54.9 MB'],
    ['Release Date', '14 April 2026, 10:50 AM IST'],
    ['Deployment Method', 'GitHub Releases (Free)'],
    ['Download URL', 'github.com/Mahalakshmi77777/IT_CYBERNUARTS/releases/tag/v1.0.0'],
]
story.append(make_table(summary_data))
story.append(Spacer(1, 8))

# ── Section 2: Technology Stack ──
story.append(Paragraph("2. Technology Stack", styles['SectionHead']))
tech_data = [
    ['Layer', 'Technology'],
    ['Frontend', 'Flutter 3.x (Dart)'],
    ['State Management', 'Riverpod'],
    ['Routing', 'GoRouter'],
    ['Backend (Auth)', 'Supabase Authentication'],
    ['Backend (Database)', 'Supabase PostgreSQL'],
    ['Backend (Storage)', 'Supabase Storage'],
    ['Version Control', 'Git + GitHub'],
    ['Deployment', 'GitHub Releases'],
]
story.append(make_table(tech_data))
story.append(Spacer(1, 8))

# ── Section 3: Backend Configuration ──
story.append(Paragraph("3. Backend Configuration", styles['SectionHead']))
backend_data = [
    ['Service', 'Details'],
    ['Supabase Project', 'mbqoxgkxzkhylisobbco.supabase.co'],
    ['Database', 'PostgreSQL (Supabase-hosted)'],
    ['Storage Bucket', 'event-images (Public)'],
    ['Authentication', 'Email + Password (Supabase Auth)'],
    ['Row Level Security', 'Enabled on all 4 tables'],
]
story.append(make_table(backend_data))
story.append(Spacer(1, 6))

story.append(Paragraph("<b>Database Tables:</b>", styles['BodyText2']))
tables_info = [
    "• <b>public.users</b> — User profiles linked to Supabase Auth",
    "• <b>public.clubs</b> — Club information",
    "• <b>public.events</b> — Events with cloud-hosted banner URLs",
    "• <b>public.registrations</b> — User-Event registrations",
]
for t in tables_info:
    story.append(Paragraph(t, styles['BodyText2']))
story.append(Spacer(1, 8))

# ── Section 4: Application Features ──
story.append(Paragraph("4. Application Features", styles['SectionHead']))

story.append(Paragraph("<b>Admin Panel</b>", styles['BodyText2']))
admin_features = [
    "✓ Create, edit, and delete events with image uploads",
    "✓ Upload event banners to Supabase Storage",
    "✓ Set event details: title, description, venue, dates, tags",
    "✓ View registered participants",
]
for f in admin_features:
    story.append(Paragraph(f, styles['BodyText2']))

story.append(Spacer(1, 6))
story.append(Paragraph("<b>User Panel</b>", styles['BodyText2']))
user_features = [
    "✓ Browse all upcoming events with banner images",
    "✓ Register / Unregister for events",
    "✓ View personal registered events",
    "✓ User profile management",
]
for f in user_features:
    story.append(Paragraph(f, styles['BodyText2']))

story.append(Spacer(1, 6))
story.append(Paragraph("<b>Security</b>", styles['BodyText2']))
security_features = [
    "✓ Role-based access control (Admin vs User)",
    "✓ Row Level Security (RLS) on all database tables",
    "✓ Authenticated storage uploads with RLS policies",
    "✓ Secure session management via Supabase Auth SDK",
]
for f in security_features:
    story.append(Paragraph(f, styles['BodyText2']))
story.append(Spacer(1, 8))

# ── Section 5: Source Code Repository ──
story.append(Paragraph("5. Source Code Repository", styles['SectionHead']))
repo_data = [
    ['Field', 'Details'],
    ['Repository URL', 'github.com/Mahalakshmi77777/IT_CYBERNUARTS'],
    ['Branch', 'main'],
    ['Total Commits', '6'],
    ['Latest Commit', '9e408ae — fix: UUID type mismatch'],
]
story.append(make_table(repo_data))
story.append(Spacer(1, 6))

story.append(Paragraph("<b>Commit History:</b>", styles['BodyText2']))
commits = [
    "9e408ae  fix: resolve UUID type mismatch for club_id",
    "bd8131c  feat: Supabase migration + warm minimal redesign",
    "e844986  chore: push UI updates and mock implementations",
    "12ef96e  Update app name and implement login profiles",
    "e67fcf5  chore: Integrate Shorebird prototype configs",
    "0709700  Initial commit",
]
for c in commits:
    story.append(Paragraph(c, styles['CommitStyle']))
story.append(Spacer(1, 8))

# ── Section 6: Release Artifact ──
story.append(Paragraph("6. Release Artifact", styles['SectionHead']))
artifact_data = [
    ['Field', 'Details'],
    ['File', 'app-release.apk'],
    ['Size', '52.31 MiB (54.9 MB)'],
    ['Build Mode', 'Release (optimized, tree-shaken)'],
    ['Min Android SDK', '21 (Android 5.0 Lollipop)'],
    ['SHA-256', '33d90dc0c7b3ec2693fb3eaeeb5ee33...'],
]
story.append(make_table(artifact_data))
story.append(Spacer(1, 12))

# ── Section 7: Proof of Deployment ──
story.append(Paragraph("7. Proof of Deployment", styles['SectionHead']))
story.append(Paragraph(
    "<b>GitHub Release URL (Live & Publicly Accessible):</b>",
    styles['BodyText2']
))
story.append(Paragraph(
    '<font color="#B24C38"><b>https://github.com/vedhan7/IT_CYBERNERDS/releases/tag/v1.0.0</b></font>',
    styles['BodyText2']
))
story.append(Spacer(1, 8))
story.append(Paragraph(
    "This URL is publicly accessible. Anyone can verify the deployment "
    "by visiting the link and downloading the APK.",
    styles['BodyText2']
))
story.append(Spacer(1, 16))

# ── Footer ──
story.append(HRFlowable(width="100%", thickness=1, color=MUTED_MUSTARD))
story.append(Spacer(1, 6))
story.append(Paragraph(
    "<i>This document serves as official proof of deployment for the IT CLUB mobile application.</i>",
    ParagraphStyle('Footer', parent=styles['Normal'], fontSize=8,
                   textColor=HexColor('#999999'), alignment=TA_CENTER)
))
story.append(Paragraph(
    "<i>Generated on: 14 April 2026</i>",
    ParagraphStyle('Footer2', parent=styles['Normal'], fontSize=8,
                   textColor=HexColor('#999999'), alignment=TA_CENTER)
))

# Build
doc.build(story)
print(f"✅ PDF generated: {output_path}")
