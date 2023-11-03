# Generated by Django 4.1.3 on 2023-02-23 10:28

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('wflow', '0005_house_house_type'),
    ]

    operations = [
        migrations.AlterField(
            model_name='house',
            name='house_type',
            field=models.CharField(choices=[('SFH', 'Single-Family House'), ('SDH', 'Semi-Detached House'), ('MFH', 'Multifamily House'), ('APA', 'Apartment'), ('CON', 'Condominium'), ('COP', 'Co-Op'), ('TIN', 'Tiny House'), ('MAN', 'Manufactured House')], max_length=3),
        ),
    ]
