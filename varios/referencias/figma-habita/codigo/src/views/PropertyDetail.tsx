import { useState } from "react";
import Logo from "../components/Logo";
import { Btn, Badge, Modal, Alert } from "../components/ui";

const GALLERY = [
  "https://images.unsplash.com/photo-1754999809963-79a41e8fb648?w=900&h=600&fit=crop&auto=format",
  "https://images.unsplash.com/photo-1786462543687-26614deb2d6f?w=900&h=600&fit=crop&auto=format",
  "https://images.unsplash.com/photo-1782803432396-e168aa0e54a1?w=900&h=600&fit=crop&auto=format",
  "https://images.unsplash.com/photo-1780147343308-7ede77816ee6?w=900&h=600&fit=crop&auto=format",
];

interface DetailProps {
  onNavigate: (view: string, extra?: object) => void;
}

export default function PropertyDetail({ onNavigate }: DetailProps) {
  const [activeImg, setActiveImg] = useState(0);
  const [showInfo, setShowInfo] = useState(false);
  const [showCita, setShowCita] = useState(false);
  const [liked, setLiked] = useState(false);
  const [successMsg, setSuccessMsg] = useState("");

  function handleSolicitar() {
    setShowInfo(false);
    setSuccessMsg("¡Solicitud enviada! La inmobiliaria te contactará en menos de 24 horas.");
    setTimeout(() => setSuccessMsg(""), 5000);
  }

  function handleCita() {
    setShowCita(false);
    setSuccessMsg("¡Cita agendada con éxito! Recibirás un correo de confirmación.");
    setTimeout(() => setSuccessMsg(""), 5000);
  }

  return (
    <div className="min-h-screen bg-[#F7F2E8]">
      {/* Header */}
      <header className="bg-[#243B32] sticky top-0 z-40">
        <div className="max-w-[1440px] mx-auto px-6 lg:px-12 h-16 flex items-center gap-4">
          <button onClick={() => onNavigate("home")}><Logo size="md" variant="light" /></button>
          <button onClick={() => onNavigate("catalog")} className="text-[#E8D8C4]/70 hover:text-[#E8D8C4] text-sm transition-colors ml-4">← Volver al catálogo</button>
        </div>
      </header>

      <div className="max-w-[1440px] mx-auto px-6 lg:px-12 py-8">
        {/* Breadcrumb */}
        <nav className="text-xs text-[#6b7280] mb-6 flex items-center gap-1.5">
          <button onClick={() => onNavigate("home")} className="hover:text-[#C96E4B]">Inicio</button>
          <span>/</span>
          <button onClick={() => onNavigate("catalog")} className="hover:text-[#C96E4B]">Propiedades</button>
          <span>/</span>
          <span className="text-[#252525]">Chapinero Alto, Bogotá</span>
        </nav>

        {successMsg && (
          <div className="mb-6 max-w-2xl">
            <Alert type="success" message={successMsg} />
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left col */}
          <div className="lg:col-span-2 space-y-8">
            {/* Gallery */}
            <div className="space-y-3">
              <div className="relative rounded-2xl overflow-hidden aspect-video bg-[#E8D8C4]">
                <img src={GALLERY[activeImg]} alt="Propiedad" className="w-full h-full object-cover" />
                <div className="absolute top-4 left-4 flex gap-2">
                  <Badge label="Venta" variant="venta" />
                  <Badge label="Disponible" variant="success" />
                </div>
                <div className="absolute bottom-4 right-4 bg-black/50 text-white text-xs px-3 py-1.5 rounded-full backdrop-blur-sm">
                  {activeImg + 1} / {GALLERY.length}
                </div>
              </div>
              <div className="flex gap-3">
                {GALLERY.map((img, i) => (
                  <button
                    key={i}
                    onClick={() => setActiveImg(i)}
                    className={`w-20 h-16 rounded-xl overflow-hidden border-2 transition-all ${activeImg === i ? "border-[#C96E4B]" : "border-transparent opacity-60 hover:opacity-100"}`}
                  >
                    <img src={img} alt="" className="w-full h-full object-cover" />
                  </button>
                ))}
              </div>
            </div>

            {/* Details */}
            <div>
              <h1 className="font-display text-3xl font-semibold text-[#243B32] leading-tight">
                Apartamento moderno en Chapinero Alto
              </h1>
              <p className="text-[#83946A] mt-2">📍 Chapinero Alto, Bogotá D.C.</p>
            </div>

            {/* Specs grid */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              {[
                { icon: "🛏", label: "Habitaciones", val: "3" },
                { icon: "🚿", label: "Baños", val: "2" },
                { icon: "📐", label: "Área total", val: "85 m²" },
                { icon: "🏢", label: "Piso", val: "7° piso" },
                { icon: "🚗", label: "Parqueaderos", val: "1" },
                { icon: "🏗", label: "Año construcción", val: "2019" },
                { icon: "🌡", label: "Estrato", val: "4" },
                { icon: "🏠", label: "Tipo", val: "Apartamento" },
              ].map(s => (
                <div key={s.label} className="bg-[#E8D8C4] rounded-xl p-4 text-center">
                  <div className="text-2xl mb-1">{s.icon}</div>
                  <p className="font-semibold text-[#243B32] text-sm">{s.val}</p>
                  <p className="text-xs text-[#6b7280] mt-0.5">{s.label}</p>
                </div>
              ))}
            </div>

            {/* Description */}
            <div>
              <h2 className="font-display text-xl font-semibold text-[#243B32] mb-4">Descripción</h2>
              <p className="text-[#3d3d3d] leading-relaxed text-sm">
                Hermoso apartamento completamente renovado ubicado en el corazón de Chapinero Alto. La unidad cuenta con acabados de alta calidad, cocina integral con muebles en madera, sala-comedor amplio con balcón privado y vista a la montaña. Los tres dormitorios tienen closets empotrados y el baño principal cuenta con ducha italiana.
              </p>
              <p className="text-[#3d3d3d] leading-relaxed text-sm mt-4">
                El conjunto residencial ofrece portería 24 horas, zona de BBQ, gimnasio comunal y parque infantil. Excelente ubicación con fácil acceso a Transmilenio, centros comerciales y restaurantes. Administración mensual: $280.000.
              </p>
            </div>

            {/* Features */}
            <div>
              <h2 className="font-display text-xl font-semibold text-[#243B32] mb-4">Características</h2>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
                {["Balcón privado", "Cocina integral", "Piso en cerámica", "Calefacción", "Portería 24h", "Parqueadero cubierto", "Zona de BBQ", "Gimnasio", "Internet fibra óptica", "Amoblado parcial", "Depósito", "Permite mascotas"].map(f => (
                  <div key={f} className="flex items-center gap-2 text-sm text-[#252525]">
                    <span className="w-5 h-5 rounded-full bg-[#83946A]/20 text-[#83946A] flex items-center justify-center text-xs font-bold">✓</span>
                    {f}
                  </div>
                ))}
              </div>
            </div>

            {/* Agency card */}
            <div className="bg-[#E8D8C4] rounded-2xl p-6">
              <h2 className="font-display text-xl font-semibold text-[#243B32] mb-5">Inmobiliaria responsable</h2>
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-xl bg-[#243B32] flex items-center justify-center text-[#F7F2E8] font-display text-xl font-bold">A</div>
                <div className="flex-1">
                  <p className="font-semibold text-[#243B32]">Alfa Inmobiliaria</p>
                  <p className="text-sm text-[#6b7280]">Bogotá • Miembro desde 2018</p>
                  <div className="flex items-center gap-1 mt-1">
                    {"★★★★☆".split("").map((s, i) => (
                      <span key={i} className={`text-sm ${s === "★" ? "text-[#C96E4B]" : "text-[#ddd6c8]"}`}>{s}</span>
                    ))}
                    <span className="text-xs text-[#6b7280] ml-1">4.2 (128 reseñas)</span>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm font-medium text-[#252525]">Asesor: Carlos Rueda</p>
                  <p className="text-xs text-[#6b7280] mt-0.5">📞 (+57) 310 456 7890</p>
                </div>
              </div>
            </div>
          </div>

          {/* Sticky sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-[#F7F2E8] border border-[#ddd6c8] rounded-2xl shadow-lg p-6 sticky top-24 space-y-4">
              <div>
                <p className="text-sm text-[#6b7280]">Precio de venta</p>
                <p className="font-display text-4xl font-semibold text-[#C96E4B] mt-1">$ 520.000.000</p>
                <p className="text-xs text-[#6b7280] mt-1">≈ USD 128.500 · Estrato 4</p>
              </div>

              <div className="border-t border-[#ddd6c8] pt-4 space-y-3">
                <Btn
                  className="w-full"
                  size="lg"
                  onClick={() => setLiked(!liked)}
                  variant={liked ? "secondary" : "outline"}
                >
                  {liked ? "♥ En favoritos" : "♡ Agregar a favoritos"}
                </Btn>
                <Btn className="w-full" size="lg" onClick={() => setShowInfo(true)}>
                  Solicitar información
                </Btn>
                <Btn className="w-full" size="lg" variant="secondary" onClick={() => setShowCita(true)}>
                  Agendar cita
                </Btn>
              </div>

              <div className="bg-[#E8D8C4] rounded-xl p-4 space-y-2.5">
                <p className="text-xs font-semibold text-[#243B32] uppercase tracking-wider">Resumen</p>
                {[
                  ["Tipo", "Apartamento"],
                  ["Ciudad", "Bogotá"],
                  ["Código", "APT-BTA-2047"],
                  ["Publicado", "15 sep 2026"],
                ].map(([k, v]) => (
                  <div key={k} className="flex justify-between text-sm">
                    <span className="text-[#6b7280]">{k}</span>
                    <span className="font-medium text-[#252525]">{v}</span>
                  </div>
                ))}
              </div>

              <p className="text-xs text-[#6b7280] text-center">¿Dudas? Escríbenos a <span className="text-[#C96E4B]">ayuda@habita.co</span></p>
            </div>
          </div>
        </div>
      </div>

      {/* Modal: Solicitar información */}
      {showInfo && (
        <Modal title="Solicitar información" onClose={() => setShowInfo(false)}>
          <div className="space-y-4">
            <p className="text-sm text-[#6b7280]">Completa tus datos y la inmobiliaria <strong>Alfa Inmobiliaria</strong> te contactará a la brevedad.</p>
            <div className="space-y-3">
              <input placeholder="Tu nombre completo" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
              <input placeholder="Correo electrónico" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
              <input placeholder="Teléfono / WhatsApp" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
              <textarea placeholder="Mensaje (opcional)" rows={3} className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none resize-none" />
            </div>
            <div className="flex gap-3">
              <Btn variant="ghost" onClick={() => setShowInfo(false)} className="flex-1">Cancelar</Btn>
              <Btn className="flex-1" onClick={handleSolicitar}>Enviar solicitud</Btn>
            </div>
          </div>
        </Modal>
      )}

      {/* Modal: Agendar cita */}
      {showCita && (
        <Modal title="Agendar cita de visita" onClose={() => setShowCita(false)}>
          <div className="space-y-4">
            <p className="text-sm text-[#6b7280]">Selecciona fecha y hora para visitar <strong>Chapinero Alto #704</strong>.</p>
            <div className="space-y-3">
              <input placeholder="Tu nombre completo" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
              <input type="date" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
              <select className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none">
                <option>10:00 AM</option>
                <option>11:00 AM</option>
                <option>2:00 PM</option>
                <option>3:30 PM</option>
                <option>5:00 PM</option>
              </select>
              <textarea placeholder="Observaciones adicionales (opcional)" rows={2} className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none resize-none" />
            </div>
            <div className="flex gap-3">
              <Btn variant="ghost" onClick={() => setShowCita(false)} className="flex-1">Cancelar</Btn>
              <Btn variant="secondary" className="flex-1" onClick={handleCita}>Confirmar cita</Btn>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}
