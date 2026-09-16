import { useState } from "react";
import Logo from "../components/Logo";
import { Btn, Badge, Card, StatCard, EmptyState, Alert, Modal } from "../components/ui";

type Tab = "resumen" | "propiedades" | "nueva" | "citas" | "solicitudes" | "documentos";

const MY_PROPS = [
  { id: 1, title: "Apartamento Chapinero Alto #704", price: "$ 520.000.000", modalidad: "venta", estado: "Activa", visitas: 142, img: "https://images.unsplash.com/photo-1754999809963-79a41e8fb648?w=400&h=260&fit=crop&auto=format" },
  { id: 2, title: "Oficina Salitre 320", price: "$ 6.800.000/mes", modalidad: "arriendo", estado: "Activa", visitas: 89, img: "https://images.unsplash.com/photo-1780147343308-7ede77816ee6?w=400&h=260&fit=crop&auto=format" },
  { id: 3, title: "Apartaestudio Zona Rosa", price: "$ 2.100.000/mes", modalidad: "arriendo", estado: "Negociando", visitas: 205, img: "https://images.unsplash.com/photo-1757924461488-ef9ad0670978?w=400&h=260&fit=crop&auto=format" },
];

const CITAS_AGENCIA = [
  { id: 1, propiedad: "Apartamento Chapinero #704", cliente: "Laura Rodríguez", fecha: "20 sep 2026", hora: "10:00 AM", estado: "Confirmada" },
  { id: 2, propiedad: "Oficina Salitre 320", cliente: "Empresa TechCol S.A.S.", fecha: "21 sep 2026", hora: "2:30 PM", estado: "Pendiente" },
  { id: 3, propiedad: "Apartaestudio Zona Rosa", cliente: "Andrés Martínez", fecha: "18 sep 2026", hora: "11:00 AM", estado: "Completada" },
];

interface AgencyProps { onNavigate: (view: string, extra?: object) => void; }

export default function AgencyPanel({ onNavigate }: AgencyProps) {
  const [tab, setTab] = useState<Tab>("resumen");

  const sidebarLinks: { id: Tab; label: string; icon: string }[] = [
    { id: "resumen", label: "Resumen", icon: "◉" },
    { id: "propiedades", label: "Mis propiedades", icon: "🏠" },
    { id: "nueva", label: "Publicar propiedad", icon: "+" },
    { id: "citas", label: "Citas recibidas", icon: "📅" },
    { id: "solicitudes", label: "Solicitudes", icon: "✉" },
    { id: "documentos", label: "Documentos", icon: "📄" },
  ];

  return (
    <div className="min-h-screen bg-[#F7F2E8] flex flex-col">
      <header className="bg-[#243B32] h-16 flex items-center px-6 justify-between sticky top-0 z-40">
        <button onClick={() => onNavigate("home")}><Logo size="md" variant="light" /></button>
        <div className="flex items-center gap-3">
          <span className="text-[#E8D8C4]/70 text-sm hidden sm:block">Alfa Inmobiliaria</span>
          <div className="w-8 h-8 rounded-xl bg-[#C96E4B] flex items-center justify-center text-white text-sm font-bold">A</div>
          <Btn variant="ghost" size="sm" onClick={() => onNavigate("home")} className="text-[#E8D8C4]/70 hover:bg-white/10 text-xs">Salir</Btn>
        </div>
      </header>

      <div className="flex flex-1 max-w-[1440px] mx-auto w-full">
        <aside className="w-64 shrink-0 bg-white border-r border-[#ddd6c8] hidden md:flex flex-col pt-8 pb-6 px-4">
          <div className="mb-8 px-3">
            <p className="font-semibold text-[#252525]">Alfa Inmobiliaria</p>
            <p className="text-xs text-[#6b7280] mt-0.5">Bogotá · Miembro desde 2018</p>
            <div className="mt-2"><Badge label="Plan Pro" variant="venta" /></div>
          </div>
          <nav className="space-y-1 flex-1">
            {sidebarLinks.map(l => (
              <button
                key={l.id}
                onClick={() => setTab(l.id)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all text-left ${tab === l.id ? "bg-[#243B32] text-[#F7F2E8]" : "text-[#6b7280] hover:bg-[#F7F2E8] hover:text-[#252525]"}`}
              >
                <span>{l.icon}</span> {l.label}
              </button>
            ))}
          </nav>
        </aside>

        <main className="flex-1 min-w-0 p-6 lg:p-8">
          {tab === "resumen" && <AgencyResumen setTab={setTab} />}
          {tab === "propiedades" && <PropiedadesTab onNavigate={onNavigate} />}
          {tab === "nueva" && <NuevaPropertyTab onBack={() => setTab("propiedades")} />}
          {tab === "citas" && <CitasAgencia />}
          {tab === "solicitudes" && <SolicitudesAgencia />}
          {tab === "documentos" && <DocumentosAgencia />}
        </main>
      </div>
    </div>
  );
}

function AgencyResumen({ setTab }: { setTab: (t: Tab) => void }) {
  return (
    <div>
      <div className="mb-8">
        <h1 className="font-display text-3xl font-semibold text-[#243B32]">Panel de inmobiliaria</h1>
        <p className="text-[#6b7280] mt-1">Gestiona tus propiedades, citas y solicitudes.</p>
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Propiedades activas" value="3" icon="🏠" trend="+1 este mes" />
        <StatCard label="Visitas totales" value="436" icon="👁" trend="+28 esta semana" />
        <StatCard label="Citas pendientes" value="2" icon="📅" />
        <StatCard label="Solicitudes nuevas" value="5" icon="✉" trend="3 sin revisar" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-display text-xl font-semibold text-[#243B32]">Propiedades recientes</h2>
            <button onClick={() => setTab("propiedades")} className="text-sm text-[#C96E4B] hover:underline">Ver todas</button>
          </div>
          <div className="space-y-3">
            {MY_PROPS.map(p => (
              <Card key={p.id} className="p-4 flex items-center gap-3">
                <div className="w-14 h-14 rounded-xl overflow-hidden bg-[#E8D8C4] shrink-0">
                  <img src={p.img} alt={p.title} className="w-full h-full object-cover" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-[#252525] text-sm truncate">{p.title}</p>
                  <p className="text-xs text-[#C96E4B] font-semibold">{p.price}</p>
                </div>
                <Badge label={p.estado} variant={p.estado === "Activa" ? "success" : "warning"} />
              </Card>
            ))}
          </div>
        </div>

        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-display text-xl font-semibold text-[#243B32]">Próximas citas</h2>
            <button onClick={() => setTab("citas")} className="text-sm text-[#C96E4B] hover:underline">Ver todas</button>
          </div>
          <div className="space-y-3">
            {CITAS_AGENCIA.filter(c => c.estado !== "Completada").map(c => (
              <Card key={c.id} className="p-4">
                <div className="flex items-start justify-between">
                  <div>
                    <p className="font-medium text-[#252525] text-sm">{c.propiedad}</p>
                    <p className="text-xs text-[#6b7280] mt-0.5">👤 {c.cliente}</p>
                    <p className="text-xs text-[#6b7280]">📅 {c.fecha} · {c.hora}</p>
                  </div>
                  <Badge label={c.estado} variant={c.estado === "Confirmada" ? "success" : "warning"} />
                </div>
              </Card>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-[#C96E4B] rounded-2xl p-6 flex items-center justify-between gap-6">
        <div>
          <p className="font-display text-xl font-semibold text-white">¿Tienes más propiedades?</p>
          <p className="text-white/80 text-sm mt-1">Publica nuevas propiedades y llega a miles de clientes potenciales.</p>
        </div>
        <Btn variant="ghost" onClick={() => setTab("nueva")} className="bg-white text-[#C96E4B] hover:bg-white/90 shrink-0">
          + Publicar propiedad
        </Btn>
      </div>
    </div>
  );
}

function PropiedadesTab({ onNavigate }: { onNavigate: (v: string, e?: object) => void }) {
  const [showDelete, setShowDelete] = useState<number | null>(null);

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h1 className="font-display text-3xl font-semibold text-[#243B32]">Mis propiedades</h1>
        <Btn>+ Publicar nueva</Btn>
      </div>
      <div className="overflow-x-auto rounded-2xl border border-[#ddd6c8]">
        <table className="w-full text-sm">
          <thead className="bg-[#E8D8C4]">
            <tr>
              {["Propiedad", "Modalidad", "Precio", "Estado", "Visitas", ""].map(h => (
                <th key={h} className="text-left px-5 py-3.5 font-semibold text-[#243B32] text-xs uppercase tracking-wider whitespace-nowrap">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-[#f0e8dc]">
            {MY_PROPS.map(p => (
              <tr key={p.id} className="hover:bg-[#F7F2E8] transition-colors">
                <td className="px-5 py-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg overflow-hidden bg-[#E8D8C4] shrink-0">
                      <img src={p.img} alt={p.title} className="w-full h-full object-cover" />
                    </div>
                    <span className="font-medium text-[#252525] line-clamp-1">{p.title}</span>
                  </div>
                </td>
                <td className="px-5 py-4"><Badge label={p.modalidad === "venta" ? "Venta" : "Arriendo"} variant={p.modalidad === "venta" ? "venta" : "arriendo"} /></td>
                <td className="px-5 py-4 font-semibold text-[#C96E4B] whitespace-nowrap">{p.price}</td>
                <td className="px-5 py-4"><Badge label={p.estado} variant={p.estado === "Activa" ? "success" : "warning"} /></td>
                <td className="px-5 py-4 text-[#6b7280]">{p.visitas}</td>
                <td className="px-5 py-4">
                  <div className="flex items-center gap-2">
                    <Btn size="sm" variant="ghost" onClick={() => onNavigate("detail", { id: p.id })}>Ver</Btn>
                    <Btn size="sm" variant="ghost">Editar</Btn>
                    <Btn size="sm" variant="danger" onClick={() => setShowDelete(p.id)}>Eliminar</Btn>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showDelete && (
        <Modal title="Confirmar eliminación" onClose={() => setShowDelete(null)}>
          <p className="text-sm text-[#6b7280] mb-6">¿Estás seguro de que deseas eliminar esta propiedad? Esta acción no se puede deshacer.</p>
          <div className="flex gap-3">
            <Btn variant="ghost" className="flex-1" onClick={() => setShowDelete(null)}>Cancelar</Btn>
            <Btn variant="danger" className="flex-1" onClick={() => setShowDelete(null)}>Sí, eliminar</Btn>
          </div>
        </Modal>
      )}
    </div>
  );
}

function NuevaPropertyTab({ onBack }: { onBack: () => void }) {
  const [success, setSuccess] = useState(false);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSuccess(true);
    setTimeout(() => { setSuccess(false); onBack(); }, 2000);
  }

  return (
    <div className="max-w-2xl">
      <div className="flex items-center gap-4 mb-8">
        <button onClick={onBack} className="text-[#6b7280] hover:text-[#C96E4B] text-sm">← Volver</button>
        <h1 className="font-display text-3xl font-semibold text-[#243B32]">Publicar propiedad</h1>
      </div>
      {success && <div className="mb-6"><Alert type="success" message="¡Propiedad publicada con éxito! Ya está visible en el catálogo." /></div>}
      <form onSubmit={handleSubmit}>
        <Card className="p-6 space-y-5 mb-6">
          <h2 className="font-display text-lg font-semibold text-[#243B32]">Información básica</h2>
          <div>
            <label className="text-sm font-medium text-[#252525] block mb-1.5">Título del anuncio</label>
            <input required placeholder="Ej: Apartamento moderno con vista a la montaña" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-medium text-[#252525] block mb-1.5">Tipo de inmueble</label>
              <select className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none">
                <option>Apartamento</option>
                <option>Casa</option>
                <option>Oficina</option>
                <option>Local</option>
                <option>Bodega</option>
              </select>
            </div>
            <div>
              <label className="text-sm font-medium text-[#252525] block mb-1.5">Modalidad</label>
              <select className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none">
                <option>Venta</option>
                <option>Arriendo</option>
              </select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-sm font-medium text-[#252525] block mb-1.5">Ciudad</label>
              <select className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none">
                <option>Bogotá</option>
                <option>Medellín</option>
                <option>Cali</option>
                <option>Barranquilla</option>
              </select>
            </div>
            <div>
              <label className="text-sm font-medium text-[#252525] block mb-1.5">Barrio / Sector</label>
              <input placeholder="Ej: Chapinero Alto" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
            </div>
          </div>
          <div>
            <label className="text-sm font-medium text-[#252525] block mb-1.5">Precio (COP)</label>
            <input placeholder="Ej: 520000000" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
          </div>
        </Card>

        <Card className="p-6 space-y-5 mb-6">
          <h2 className="font-display text-lg font-semibold text-[#243B32]">Características</h2>
          <div className="grid grid-cols-3 gap-4">
            {[["Habitaciones", "3"], ["Baños", "2"], ["Área (m²)", "85"]].map(([l, p]) => (
              <div key={l}>
                <label className="text-sm font-medium text-[#252525] block mb-1.5">{l}</label>
                <input placeholder={p} className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
              </div>
            ))}
          </div>
          <div>
            <label className="text-sm font-medium text-[#252525] block mb-3">Características adicionales</label>
            <div className="grid grid-cols-3 gap-2">
              {["Parqueadero", "Piscina", "Gym", "Terraza", "Ascensor", "Amoblado", "Depósito", "Portería 24h", "Mascotas"].map(f => (
                <label key={f} className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" className="accent-[#C96E4B] w-4 h-4" />
                  <span className="text-sm text-[#252525]">{f}</span>
                </label>
              ))}
            </div>
          </div>
        </Card>

        <Card className="p-6 space-y-5 mb-6">
          <h2 className="font-display text-lg font-semibold text-[#243B32]">Descripción</h2>
          <textarea placeholder="Describe detalladamente la propiedad: acabados, ubicación, ventajas del sector..." rows={5} className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none resize-none" />
        </Card>

        <Card className="p-6 mb-8">
          <h2 className="font-display text-lg font-semibold text-[#243B32] mb-4">Fotografías</h2>
          <div className="border-2 border-dashed border-[#ddd6c8] rounded-xl p-10 text-center hover:border-[#C96E4B] transition-colors cursor-pointer">
            <div className="text-4xl mb-3">📸</div>
            <p className="font-medium text-[#252525] text-sm">Arrastra fotos aquí o haz clic para seleccionarlas</p>
            <p className="text-xs text-[#6b7280] mt-1">JPG, PNG · Máximo 20 fotos · 10 MB por foto</p>
          </div>
        </Card>

        <div className="flex gap-3">
          <Btn type="submit" size="lg">Publicar propiedad</Btn>
          <Btn variant="ghost" size="lg" type="button" onClick={onBack}>Cancelar</Btn>
        </div>
      </form>
    </div>
  );
}

function CitasAgencia() {
  return (
    <div>
      <h1 className="font-display text-3xl font-semibold text-[#243B32] mb-8">Citas recibidas</h1>
      <div className="space-y-3">
        {CITAS_AGENCIA.map(c => (
          <Card key={c.id} className="p-5">
            <div className="flex items-start justify-between gap-4 flex-wrap">
              <div>
                <p className="font-semibold text-[#252525]">{c.propiedad}</p>
                <p className="text-sm text-[#6b7280] mt-1">👤 {c.cliente}</p>
                <p className="text-sm text-[#6b7280]">📅 {c.fecha} · {c.hora}</p>
              </div>
              <div className="flex items-center gap-3">
                <Badge label={c.estado} variant={c.estado === "Confirmada" ? "success" : c.estado === "Pendiente" ? "warning" : "neutral"} />
                {c.estado === "Pendiente" && (
                  <div className="flex gap-2">
                    <Btn size="sm" variant="secondary">Confirmar</Btn>
                    <Btn size="sm" variant="danger">Rechazar</Btn>
                  </div>
                )}
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

function SolicitudesAgencia() {
  return (
    <div>
      <h1 className="font-display text-3xl font-semibold text-[#243B32] mb-8">Solicitudes de clientes</h1>
      <div className="overflow-x-auto rounded-2xl border border-[#ddd6c8]">
        <table className="w-full text-sm">
          <thead className="bg-[#E8D8C4]">
            <tr>
              {["Cliente", "Propiedad", "Fecha", "Estado", ""].map(h => (
                <th key={h} className="text-left px-5 py-3.5 font-semibold text-[#243B32] text-xs uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-[#f0e8dc]">
            {[
              { cliente: "Laura Rodríguez", propiedad: "Apartamento Chapinero #704", fecha: "16 sep 2026", estado: "Nueva" },
              { cliente: "TechCol S.A.S.", propiedad: "Oficina Salitre 320", fecha: "15 sep 2026", estado: "En revisión" },
              { cliente: "Andrés Martínez", propiedad: "Apartaestudio Zona Rosa", fecha: "14 sep 2026", estado: "Respondida" },
              { cliente: "María Gómez", propiedad: "Apartamento Chapinero #704", fecha: "13 sep 2026", estado: "Respondida" },
              { cliente: "Felipe Suárez", propiedad: "Oficina Salitre 320", fecha: "12 sep 2026", estado: "Archivada" },
            ].map((s, i) => (
              <tr key={i} className="hover:bg-[#F7F2E8] transition-colors">
                <td className="px-5 py-4 font-medium text-[#252525]">{s.cliente}</td>
                <td className="px-5 py-4 text-[#6b7280]">{s.propiedad}</td>
                <td className="px-5 py-4 text-[#6b7280]">{s.fecha}</td>
                <td className="px-5 py-4">
                  <Badge label={s.estado} variant={s.estado === "Nueva" ? "venta" : s.estado === "Respondida" ? "success" : s.estado === "En revisión" ? "warning" : "neutral"} />
                </td>
                <td className="px-5 py-4"><Btn size="sm" variant="ghost">Responder</Btn></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function DocumentosAgencia() {
  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h1 className="font-display text-3xl font-semibold text-[#243B32]">Documentos de clientes</h1>
      </div>
      <Alert type="info" message="Revisa los documentos enviados por los interesados para validar su perfil antes de avanzar." />
      <div className="mt-6 space-y-3">
        {[
          { cliente: "Laura Rodríguez", doc: "Cédula de ciudadanía.pdf", propiedad: "Apartamento Chapinero #704", estado: "Pendiente revisión" },
          { cliente: "Laura Rodríguez", doc: "Desprendibles de nómina.pdf", propiedad: "Apartamento Chapinero #704", estado: "Pendiente revisión" },
          { cliente: "Andrés Martínez", doc: "Cédula de ciudadanía.pdf", propiedad: "Apartaestudio Zona Rosa", estado: "Verificado" },
        ].map((d, i) => (
          <Card key={i} className="p-4 flex items-center gap-4">
            <div className="w-10 h-10 rounded-xl bg-[#E8D8C4] flex items-center justify-center text-xl">📄</div>
            <div className="flex-1">
              <p className="font-medium text-[#252525] text-sm">{d.doc}</p>
              <p className="text-xs text-[#6b7280]">{d.cliente} · {d.propiedad}</p>
            </div>
            <Badge label={d.estado} variant={d.estado === "Verificado" ? "success" : "warning"} />
            <div className="flex gap-2">
              <Btn size="sm" variant="ghost">Ver</Btn>
              {d.estado !== "Verificado" && <Btn size="sm" variant="secondary">Aprobar</Btn>}
            </div>
          </Card>
        ))}
      </div>

      {/* Empty state for future docs */}
      <div className="mt-10">
        <EmptyState icon="📁" title="Carpetas de expedientes" description="Aquí aparecerán los expedientes completos de clientes por propiedad." />
      </div>
    </div>
  );
}
