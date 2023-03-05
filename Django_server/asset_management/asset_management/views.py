from django.shortcuts import redirect

# Create your views here.
def HomeView(request):
    return redirect('admin/')