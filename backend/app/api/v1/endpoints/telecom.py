"""
Krishi-Saarthi Telecom Gateway Endpoints (USSD & SMS)
Provides real telecom endpoints for 2G rural phones, interactive *123# sessions, and SMS alerts.
"""
from fastapi import APIRouter
from pydantic import BaseModel, Field
from typing import Optional, List
from app.services.sms_ussd_service import TelecomGatewayService

router = APIRouter(prefix="/telecom", tags=["Telecom Gateway (USSD & SMS)"])


class USSDSessionRequest(BaseModel):
    session_id: str = Field(..., description="Unique telecom session identifier")
    msisdn: str = Field(..., description="Farmer phone number (MSISDN)")
    user_input: str = Field("*123#", description="Keypad input sequence or shortcode")
    service_code: str = Field("*123#", description="USSD service code")


class SendSMSRequest(BaseModel):
    recipient: str = Field(..., description="Farmer 10-digit mobile number")
    message: str = Field(..., description="SMS message text (Hindi or English)")
    dlt_template_id: Optional[str] = Field("DLT-AGRI-10029", description="TRAI DLT Template ID")
    priority: Optional[str] = Field("HIGH", description="Priority level ('HIGH', 'NORMAL', 'EMERGENCY')")


class InboundSMSRequest(BaseModel):
    sender: str = Field(..., description="Farmer mobile number who sent the SMS")
    body: str = Field(..., description="SMS text content (e.g., 'CROP WHEAT RUST')")


@router.post("/ussd/session")
async def process_ussd(req: USSDSessionRequest):
    """Processes interactive USSD telecom session request (*123#). Returns CON/END frames."""
    return TelecomGatewayService.handle_ussd_session(
        session_id=req.session_id,
        msisdn=req.msisdn,
        user_input=req.user_input,
        service_code=req.service_code
    )


@router.post("/sms/send")
async def send_sms(req: SendSMSRequest):
    """Dispatches DLT-compliant SMS to farmer phone number via Indian carrier routing."""
    return TelecomGatewayService.send_sms(
        recipient=req.recipient,
        message=req.message,
        dlt_template_id=req.dlt_template_id or "DLT-AGRI-10029",
        priority=req.priority or "HIGH"
    )


@router.post("/sms/inbound")
async def inbound_sms_webhook(req: InboundSMSRequest):
    """Inbound webhook receiving SMS queries from 2G feature phones and returning auto-replies."""
    return TelecomGatewayService.handle_inbound_sms(
        sender=req.sender,
        body=req.body
    )


@router.get("/sms/logs")
async def get_sms_logs():
    """Retrieves transmission logs and delivery reports of recent SMS messages."""
    return {
        "count": len(TelecomGatewayService.get_logs()),
        "logs": TelecomGatewayService.get_logs()
    }


@router.get("/stats")
async def get_telecom_stats():
    """Returns real-time carrier delivery SLA, active USSD sessions, and telecom latency."""
    return TelecomGatewayService.get_carrier_stats()
