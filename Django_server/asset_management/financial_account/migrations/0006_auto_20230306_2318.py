# Generated by Django 3.2 on 2023-03-06 23:18

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('financial_account', '0005_auto_20230306_2307'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='payaccount',
            name='bankconnection',
        ),
        migrations.AddField(
            model_name='payaccount',
            name='bankconnection',
            field=models.ManyToManyField(related_name='connectpay', to='financial_account.Financialaccount'),
        ),
        migrations.RemoveField(
            model_name='payaccount',
            name='cardconnection',
        ),
        migrations.AddField(
            model_name='payaccount',
            name='cardconnection',
            field=models.ManyToManyField(related_name='connectpay', to='financial_account.Cardaccount'),
        ),
    ]
