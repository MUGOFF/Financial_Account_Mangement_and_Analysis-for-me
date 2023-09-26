from rest_framework import serializers
from .models import *
import json

class MonthlyBookInfoSerializer(serializers.ModelSerializer):
    string_to_json = serializers.SerializerMethodField()
    
    class Meta:
        model = MonthlyBookSetting
        fields = ('__all__')
        
    def get_string_to_json(self, obj):
        return json.loads(obj.json_string)