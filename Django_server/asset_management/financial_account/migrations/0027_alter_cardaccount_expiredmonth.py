# Generated by Django 3.2 on 2023-03-31 13:12

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('financial_account', '0026_alter_cardaccount_expiredmonth'),
    ]

    operations = [
        migrations.AlterField(
            model_name='cardaccount',
            name='expiredmonth',
            field=models.DateField(default=datetime.date(2023, 3, 31)),
        ),
    ]
