from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .serializers import *
from datetime import date

# Create your views here.
class Company_Nickname(ModelViewSet):
    # queryset = Company_Category_Correlation.objects.all()
    serializer_class = Company_nicknameSettingSerializer
    
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            return Company_Category_Correlation.objects.all()
        else:
            # Regular user sees only their instances
            return Company_Category_Correlation.objects.filter(owner=user)
        
class Category(ModelViewSet):
    # queryset = Main_Category.objects.all()
    serializer_class = CategorySettingSerializer
    
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            return CategorySetting.objects.all()
        else:
            # Regular user sees only their instances
            return CategorySetting.objects.filter(owner=user)

# class MonthBudgetAPI(ModelViewSet):
#     # queryset = MonthlyBudgetSetting.objects.all()
#     serializer_class = BudgetSettingSerializer
    
#     def get_queryset(self):
#         user = self.request.user
#         year = self.kwargs.get('year')
#         month = self.kwargs.get('month')
        
#         if user.is_staff:
#             # Admin sees all instances
#             return MonthlyBudgetSetting.objects.all()
#         print(year, month)
#         if year is not None and month is not None:
#             # Regular user with year and month provided
#             return MonthlyBudgetSetting.objects.filter(
#                 budget_json_string__contains=f'"{year}","{month}"'  # Customize this according to your JSON structure
#             )
#         # Regular user without year and month parameters
#         return MonthlyBudgetSetting.objects.none()  # Unauthorized access without year and month parameters returns an empty queryset
    
    
class MonthBudgetAPI(APIView):
    def get(self, request, formatter=None):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            settings = MonthlyBudgetSetting.objects.all()
            serializer = BudgetSettingSerializer(settings, many=True, context={"request": request})
            return Response(serializer.data)
        
        if "default" in request.path:
            settings = MonthlyBudgetSetting.objects.filter(owner=user)
            serializer = BudgetSettingSerializer(settings, many=True, context={"request": request})
            return Response(serializer.data)
        else:
            settings = MonthlyBudgetSetting.objects.filter(owner=user)
            serializer = BudgetSettingSerializer(settings, many=True, context={"request": request})
            return Response(serializer.data)
    
    def post(self, request, formatter=None):
        post_serializer = BudgetSettingSerializer(data=request.data)
        if(post_serializer.is_valid()):
            post_serializer.save()
            return Response(post_serializer.data, status=status.HTTP_201_CREATED) #client에게 JSON response 전달
        else:
            return Response(post_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, formatter=None):
        contest_list = MonthlyBudgetSetting.objects.get(year=year, month=month)
        if contest_list != None: 
            update_content = BudgetSettingSerializer(contest_list, data=request.data)
            if update_content.is_valid():
                update_content.save()
                return Response(status=status.HTTP_204_NO_CONTENT)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
    