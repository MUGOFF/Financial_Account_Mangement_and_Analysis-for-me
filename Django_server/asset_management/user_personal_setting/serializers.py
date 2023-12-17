from rest_framework import serializers
from .models import *
from django.contrib.auth.models import User
import json


class BudgetSettingSerializer(serializers.ModelSerializer):
    string_to_json = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = MonthlyBudgetSetting
        # fields = ('__all__')
        exclude = ('owner', )

    def get_string_to_json(self, obj):
        return json.loads(obj.budget_json_string)
    
    def create(self, validated_data):
        username = validated_data.pop('username')
        if User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            instance = MonthlyBudgetSetting.objects.create(owner=user, **validated_data)
            return instance
        else:
            raise serializers.ValidationError("User with this username does not exist.")
    
class Company_nicknameSettingSerializer(serializers.ModelSerializer):
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = Company_Category_Correlation
        # fields = ('__all__')
        exclude = ('owner', )
        
    def create(self, validated_data):
        username = validated_data.pop('username')
        if User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            instance = Company_Category_Correlation.objects.create(owner=user, **validated_data)
            return instance
        else:
            raise serializers.ValidationError("User with this username does not exist.")
        
class CategorySettingSerializer(serializers.ModelSerializer):
    string_to_json = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = CategorySetting
        # fields = (
        #     'flow_category',
        #     'main_category',
        # )
        exclude = ('owner', )
      
    def get_string_to_json(self, obj):
        return json.loads(obj.category_json_string)
    
    def create(self, validated_data):
        username = validated_data.pop('username')
        if User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            instance = CategorySetting.objects.create(owner=user, **validated_data)
            return instance
        else:
            raise serializers.ValidationError("User with this username does not exist.")