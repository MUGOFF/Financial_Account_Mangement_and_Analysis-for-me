from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .serializers import *
from datetime import date
# Create your views here.

# class MonthBookAPI(APIView):
#     def get(self, request, year, month, formatter=None):
#         settings = MonthlyBookSetting.objects.filter(year=year, month=month)
#         serializer = MonthlyBookInfoSerializer(settings, many=True, context={"request": request})
#         return Response(serializer.data)
#     def post(self, request, year, month, formatter=None):
#         post_serializer = MonthlyBookInfoSerializer(data=request.data)
#         if(post_serializer.is_valid()):
#             post_serializer.save()
#             return Response(post_serializer.data, status=status.HTTP_201_CREATED) #client에게 JSON response 전달
#         else:
#             return Response(post_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
#     def put(self, request, year, month, formatter=None):
#         contest_list = MonthlyBookSetting.objects.get(year=year, month=month)
#         if contest_list != None: 
#             update_content = MonthlyBookInfoSerializer(contest_list, data=request.data)
#             if update_content.is_valid():
#                 update_content.save()
#                 return Response(status=status.HTTP_204_NO_CONTENT)
#             else:
#                 return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
#         else:
#             return Response(status=status.HTTP_400_BAD_REQUEST)