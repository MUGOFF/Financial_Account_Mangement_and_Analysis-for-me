from django.core.paginator import Paginator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .serializers import *
# Create your views here.


class TransactionBasics(APIView):
    # 전 기록 추출
    def get(self, request, accountname, format=None):
        account = Transaction.objects.all()
        # account = Transaction.objects.filter(transaction_from=accountname)
        # account = Transaction.objects.filter(transaction_from_str=accountname)
        serializer = TransactionAllSerializer(account, many=True, context={"request": request})
        return Response(serializer.data)
    def post(self, request,accountname, form=None):
        post_serializer = TransactionAllSerializer(data=request.data)
        if(post_serializer.is_valid()):
            post_serializer.save()
            return Response(post_serializer.data, status=status.HTTP_201_CREATED) #client에게 JSON response 전달
        else:
            return Response(post_serializer.errors, status=status.HTTP_400_BAD_REQUEST)