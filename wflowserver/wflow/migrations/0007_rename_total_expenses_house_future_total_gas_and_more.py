# Generated by Django 4.1.3 on 2023-02-23 10:45

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('wflow', '0006_alter_house_house_type'),
    ]

    operations = [
        migrations.RenameField(
            model_name='house',
            old_name='total_expenses',
            new_name='future_total_gas',
        ),
        migrations.AddField(
            model_name='house',
            name='future_total_liters',
            field=models.FloatField(default=345),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='house',
            name='total_gas',
            field=models.FloatField(default=6547),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='house',
            name='total_liters',
            field=models.FloatField(default=2346),
            preserve_default=False,
        ),
    ]
