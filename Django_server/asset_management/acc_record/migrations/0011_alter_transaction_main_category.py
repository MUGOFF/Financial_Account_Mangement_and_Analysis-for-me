# Generated by Django 3.2 on 2023-03-30 21:27

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('acc_record', '0010_rename_company_accoutname_company_category_correlation_company_accountname'),
    ]

    operations = [
        migrations.AlterField(
            model_name='transaction',
            name='main_category',
            field=models.CharField(default='미지정', max_length=250),
        ),
    ]
