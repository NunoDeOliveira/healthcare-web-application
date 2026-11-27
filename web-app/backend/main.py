from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI, status
from sqlmodel import Field, Session, SQLModel, create_engine, select


# -----------------------------------------
# 1. Database configuration
# -----------------------------------------

DATABASE_URL = "sqlite:///./medicore.db"

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)


# -----------------------------------------
# 2. Data models
# -----------------------------------------

class Appointment(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    patient_name: str
    specialty: str
    date: str


class AppointmentCreate(SQLModel):
    patient_name: str
    specialty: str
    date: str


class AppointmentPublic(AppointmentCreate):
    id: int


# -----------------------------------------
# 3. Database session
# -----------------------------------------

def get_session():
    with Session(engine) as session:
        yield session


SessionDep = Annotated[Session, Depends(get_session)]


# -----------------------------------------
# 4. Application setup
# -----------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    SQLModel.metadata.create_all(engine)
    yield


app = FastAPI(
    title="MediCore Health API",
    description="REST API for a fictional healthcare platform",
    version="1.0.0",
    lifespan=lifespan
)


# -----------------------------------------
# 5. Health check endpoint
# -----------------------------------------

@app.get("/health")
def health_check():
    return {"status": "ok"}


# -----------------------------------------
# 6. Medical specialties
# -----------------------------------------

@app.get("/api/specialties")
def get_specialties():
    return {
        "specialties": [
            "General Medicine",
            "Cardiology",
            "Dermatology",
            "Traumatology",
            "Pediatrics"
        ]
    }


# -----------------------------------------
# 7. Create appointment
# -----------------------------------------

@app.post(
    "/api/appointments",
    response_model=AppointmentPublic,
    status_code=status.HTTP_201_CREATED
)
def create_appointment(
    appointment: AppointmentCreate,
    session: SessionDep
):
    new_appointment = Appointment.model_validate(appointment)

    session.add(new_appointment)
    session.commit()
    session.refresh(new_appointment)

    return new_appointment


# -----------------------------------------
# 8. List appointments
# -----------------------------------------

@app.get(
    "/api/appointments",
    response_model=list[AppointmentPublic]
)
def get_appointments(session: SessionDep):

    appointments = session.exec(select(Appointment)).all()

    return appointments