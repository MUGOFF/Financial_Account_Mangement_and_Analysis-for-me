from django.core.paginator import Paginator
from rest_framework.views import APIView
from rest_framework.response import Response
from .serializers import *

# Create your views here.
class Account_Book_Bookmark(APIView):
    # 전 기록 추출
    def get(self, request, format=None):
        # account = Transaction.objects.filter(account=accountname)
        account = Financialaccount.objects.all()
        serializer = AccountTrans(account, many=True, context={"request": request})
        return Response(serializer.data)