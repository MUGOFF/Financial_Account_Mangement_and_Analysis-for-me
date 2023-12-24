from rest_framework import serializers
from .models import *
from financial_account.models import *

#Transacrion 전체 필드
class TransactionSerailizer(serializers.ModelSerializer):
    
    class Meta:
        model = Transaction
        fields = ('__all__') 
        
#Investment 전체 필드
class InvestmentSerailizer(serializers.ModelSerializer):
    
    class Meta:
        model = Investment
        fields = ('__all__') 
        
class TagBaseSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Tag_Category
        fields = (
            'sub_category',
        )
    
class TagSerializer(serializers.ModelSerializer):
    relate_transaction = serializers.SerializerMethodField()
    
    class Meta:
        model = Tag_Category
        fields = (
            # 'upper_clas_category',
            'sub_category',
            'relate_transaction',
        )
        
    def get_relate_transaction(self, obj):
        transcations = Transaction.objects.filter(sub_category=obj)
        id_list = [transaction.id for transaction in transcations]
        return id_list
        

        
class TransactionAllSerializer(serializers.ModelSerializer):
    transaction_from_str = serializers.CharField(source='transaction_from.nickname', required=False)
    transaction_from_type = serializers.CharField(source='transaction_from.bankname', required=False)
    transaction_from_card_str = serializers.CharField(source='transaction_from_card.nickname', required=False, allow_null=True)
    transaction_from_card_type = serializers.CharField(source='transaction_from_card.corpname', required=False, allow_null=True)
    # sub_category = serializers.PrimaryKeyRelatedField(many=True, allow_null=True)
    
    class Meta:
        model = Transaction
        fields = (
            'id',
            'written_datetime',
            'updated_datetime',
            'transaction_time',
            'transaction_from',
            'transaction_from_str',
            'transaction_from_type',
            'transaction_from_card',
            'transaction_from_card_str',
            'transaction_from_card_type',
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
# class MoneyCategorySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Main_Category
#         fields = (
#             'flow_category',
#             'main_category',
# class CompanyCorrelationSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Company_Category_Correlation
#         fields = (
#             'company_accountname',
#             'company_commonname',
#             'category_hook',
#         )
#         )