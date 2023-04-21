from rest_framework import serializers
from .models import *
from financial_account.models import Financialaccount

class MoneyCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Main_Category
        fields = (
            'flow_category',
            'main_category',
        )
        
class CategoryTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tag_Category
        fields = (
            'upper_clas_category',
            'sub_category',
        )
        
class CompanyCorrelationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Company_Category_Correlation
        fields = (
            'company_accountname',
            'company_commonname',
            'category_hook',
        )

class TransactionAllSerializer(serializers.ModelSerializer):
    transaction_from_str = serializers.CharField(source='transaction_from.nickname')
    transaction_from_card_str = serializers.CharField(source='transaction_from_card.nickname', allow_null=True)
        
    class Meta:
        model = Transaction
        fields = (
            'id',
            'written_datetime',
            'updated_datetime',
            'transaction_time',
            'transaction_from',
            'transaction_from_str',
            'transaction_from_card',
            'transaction_from_card_str',
            'transaction_to_name',
            'deposit_amount',
            'withdrawal_amount',
            'main_category',
            'sub_category',
            'description',
        )
          
class TransactionShowSerializer(serializers.ModelSerializer):
    
    transaction_from_str = serializers.CharField(source='transaction_from.nickname')
    transaction_to_name_nickname = serializers.CharField(source='transaction_to_name_related.compnay_commonname')
    transaction_from_card_str = serializers.CharField(source='transaction_from_card.nickname', allow_null=True)
    
    class Meta:
        model = Transaction
        fields = (
            'transaction_time',
            'transaction_to_name',
            'transaction_from_str',
            'transaction_from_card_str',
            'transaction_to_name_nickname',
            'deposit_amount',
            'withdrawal_amount',
            'main_category',
            'sub_category',
        )