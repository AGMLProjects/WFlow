# Generated by Django 4.1.3 on 2023-02-04 16:19

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_customuser_test'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='customuser',
            name='test',
        ),
    ]
