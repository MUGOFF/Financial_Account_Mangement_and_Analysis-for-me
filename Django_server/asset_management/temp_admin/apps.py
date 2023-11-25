from django.apps import AppConfig

class TempAdminConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'temp_admin'
    
    def ready(self):
        import temp_admin.signals
