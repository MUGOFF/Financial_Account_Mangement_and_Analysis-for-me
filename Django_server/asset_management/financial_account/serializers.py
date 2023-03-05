from rest_framework import serializers
from .models import *
from acc_record.serializers import TransactionAccountSerializer 

class AccountInfo(serializers.ModelSerializer):
    class Meta:
        model = Financialaccount
        fields = (
            'nickname',
            'bankname',
            'accountnumber',
            'assetamount',
        )

class AccountTrans(serializers.ModelSerializer):
    transaction = TransactionAccountSerializer(many = True, read_only = True)
    
    class Meta:
        model = Financialaccount
        fields = (
            'nickname',
            'bankname',
            'accountnumber',
            'assetamount',
            'transaction',
        )