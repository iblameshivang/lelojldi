"""
Celery application configuration for async tasks.
"""
from celery import Celery
from celery.schedules import crontab

celery_app = Celery(
    "krishi_saarthi",
    broker="redis://localhost:6379/1",
    backend="redis://localhost:6379/2",
    include=[
        "app.tasks.weather_tasks",
        "app.tasks.mandi_tasks",
        "app.tasks.kriging_tasks",
    ],
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Kolkata",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,  # 5 minutes max
    task_soft_time_limit=240,
    worker_max_tasks_per_child=100,
    worker_prefetch_multiplier=1,
)

# Scheduled tasks
celery_app.conf.beat_schedule = {
    "fetch-weather-hourly": {
        "task": "app.tasks.weather_tasks.fetch_all_weather",
        "schedule": crontab(minute=0),  # Every hour
    },
    "fetch-mandi-prices-daily": {
        "task": "app.tasks.mandi_tasks.fetch_all_mandi_prices",
        "schedule": crontab(hour=6, minute=0),  # Daily at 6 AM IST
    },
    "compute-kriging-surfaces": {
        "task": "app.tasks.kriging_tasks.compute_risk_surfaces",
        "schedule": crontab(minute="*/30"),  # Every 30 minutes
    },
}
