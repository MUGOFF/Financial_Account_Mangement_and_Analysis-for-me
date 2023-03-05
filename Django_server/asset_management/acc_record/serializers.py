from rest_framework import serializers
from .models import *
from financial_account.models import Financialaccount

class MoneyCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Flow_category
        fields = (
            'flow_category',
            'main_category',
            'sub_category',
        )

class TransactionAllSerializer(serializers.ModelSerializer):
    
    # transaction_from_dict = AccountTrans(many =)
    transaction_from_str = serializers.SerializerMethodField()
    
    class Meta:
        model = Transaction
        fields = (
            'written_datetime',
            'updated_datetime',
            'transaction_time',
            'transaction_from',
            'transaction_from_str',
            'transaction_to_name',
            'transaction_to_nickname',
            'changed_amount',
            'main_category',
            'sub_category',
            'category_hooked',
            'description',
        )
    
    def get_transaction_from_str(self, Transaction):
        print(self)
        print(self.context)
        request = self.context.get('request')
        account = Financialaccount.objects.filter(nickname = request)
        print(Financialaccount.objects.all())
        # print(account.nickname)
        return account
    
          
class TransactionAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = (
            'transaction_time',
            'transaction_to_name',
            'transaction_to_nickname',
            'changed_amount',
            'main_category',
            'sub_category',
        )