from rest_framework import serializers
from .models import *

class MoneyCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow_category
        fields = (
            'flow_category',
            'main_category',
            'sub_category',
        )

class TransactionAllSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = (
            'written_datetime',
            'updated_datetime',
            'transaction_time',
            'transaction_from',
            'transaction_to_name',
            'transaction_to_nickname',
            'changed_amount',
            'main_category',
            'sub_category',
            'category_hooked',
            'description',
        )
        
class TransactionAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = (
            'transaction_time',
            'transaction_name',
            'transaction_nickname',
            'changed_amount',
            'main_category',
            'sub_category',
        )