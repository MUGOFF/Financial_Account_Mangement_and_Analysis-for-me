# Generated by Django 3.2 on 2023-03-12 12:59

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('financial_account', '0007_auto_20230311_1538'),
    ]

    operations = [
        migrations.AddField(
            model_name='financialaccount',
            name='description',
            field=models.TextField(blank=True, default=''),
        ),
    ]
