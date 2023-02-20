# Generated by Django 3.2 on 2023-02-19 23:59

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Flow_category',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('flow_category', models.CharField(max_length=50)),
                ('main_category', models.CharField(max_length=50)),
                ('sub_category', models.CharField(max_length=50)),
            ],
        ),
        migrations.CreateModel(
            name='Transaction',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('written_datetime', models.DateTimeField(auto_now_add=True)),
                ('updated_datetime', models.DateTimeField(auto_now=True)),
                ('transaction_time', models.DateTimeField()),
                ('transaction_to_name', models.CharField(max_length=250)),
                ('transaction_to_nickname', models.CharField(max_length=250)),
                ('changed_amount', models.IntegerField(default=0)),
                ('main_category', models.CharField(max_length=250)),
                ('sub_category', models.CharField(max_length=250)),
                ('description', models.TextField(blank=True)),
                ('category_hooked', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='acc_record.flow_category')),
            ],
        ),
    ]
