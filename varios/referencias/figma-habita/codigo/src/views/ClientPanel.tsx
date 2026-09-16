import { useState } from "react";
import Logo from "../components/Logo";
import { Btn, Badge, Card, StatCard, EmptyState, Alert } from "../components/ui";

type Tab = "resumen" | "favoritos" | "citas" | "solicitudes" | "documentos" | "perfil";

const FAVORITOS = [
  { id: 1, title: "Apartamento moderno en Chapinero", price: "$ 520.000.000", city: "Bogotá", modalidad: "venta", img: "https://images.unsplash.com/photo-1754999809963-79a41e8fb648?w=400&h=260&fit=crop&auto=format" },
  { id: 2, title: "Casa familiar con jardín en El Poblado", price: "$ 4.200.000/mes", city: "Medellín", modalidad: "arriendo", img: "https://images.unsplash.com/photo-1786462543687-26614deb2d6f?w=400&h=260&fit=crop&auto=format" },
  { id: 3, title: "Penthouse con vista panorámica", price: "$ 1.200.000.000", city: "Cali", modalidad: "venta", img: "https://images.unsplash.com/photo-1782803432396-e168aa0e54a1?w=400&h=260&fit=crop&auto=format" },
];

const CITAS = [
  { id: 1, propiedad: "Apartamento Chapinero Alto #704", fecha: "20 sep 2026", hora: "10:00 AM", asesor: "Carlos Rueda", estado: "Confirmada" },
  { id: 2, propiedad: "Casa El Poblado, Medellín", fecha: "22 sep 2026", hora: "3:00 PM", asesor: "Andrea López", estado: "Pendiente" },
  { id: 3, propiedad: "Penthouse Ciudad Jardín, Cali", fecha: "18 sep 2026", hora: "11:30 AM", asesor: "Diego Vargas", estado: "Completada" },
];

const SOLICITUDES = [
  { id: 1, propiedad: "Apartamento Chapinero Alto", inmobiliaria: "Alfa Inmobiliaria", fecha: "16 sep 2026", estado: "En revisión" },
  { id: 2, propiedad: "Casa El Poblado", inmobiliaria: "Grupo Habitat", fecha: "14 sep 2026", estado: "Respondida" },
];

interface ClientProps { onNavigate: (view: string, extra?: object) => void; }

export default function ClientPanel({ onNavigate }: ClientProps) {
  const [tab, setTab] = useState<Tab>("resumen");

  const sidebarLinks: { id: Tab; label: string; icon: string }[] = [
    { id: "resumen", label: "Resumen", icon: "◉" },
    { id: "favoritos", label: "Mis favoritos", icon: "♥" },
    { id: "citas", label: "Mis citas", icon: "📅" },
    { id: "solicitudes", label: "Solicitudes", icon: "✉" },
    { id: "documentos", label: "Documentos", icon: "📄" },
    { id: "perfil", label: "Perfil", icon: "👤" },
  ];

  return (
    <div className="min-h-screen bg-[#F7F2E8] flex flex-col">
      {/* Header */}
      <header className="bg-[#243B32] h-16 flex items-center px-6 justify-between sticky top-0 z-40">
        <button onClick={() => onNavigate("home")}><Logo size="md" variant="light" /></button>
        <div className="flex items-center gap-4">
          <span className="text-[#E8D8C4]/70 text-sm hidden sm:block">Laura Rodríguez</span>
          <div className="w-8 h-8 rounded-full bg-[#C96E4B] flex items-center justify-center text-white text-sm font-semibold">L</div>
          <Btn variant="ghost" size="sm" onClick={() => onNavigate("home")} className="text-[#E8D8C4]/70 hover:bg-white/10 text-xs">
            Salir
          </Btn>
        </div>
      </header>

      <div className="flex flex-1 max-w-[1440px] mx-auto w-full px-0">
        {/* Sidebar */}
        <aside className="w-64 shrink-0 bg-white border-r border-[#ddd6c8] hidden md:flex flex-col pt-8 pb-6 px-4">
          <div className="mb-8 px-3">
            <p className="font-semibold text-[#252525]">Laura Rodríguez</p>
            <p className="text-xs text-[#6b7280] mt-0.5">laura@ejemplo.com</p>
            <Badge label="Cliente activo" variant="success" />
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
          <div className="px-3 mt-4">
            <Btn variant="outline" size="sm" className="w-full" onClick={() => onNavigate("catalog")}>
              Buscar propiedades
            </Btn>
          </div>
        </aside>

        {/* Main content */}
        <main className="flex-1 min-w-0 p-6 lg:p-8">
          {tab === "resumen" && <ResumenTab />}
          {tab === "favoritos" && <FavoritosTab onNavigate={onNavigate} />}
          {tab === "citas" && <CitasTab />}
          {tab === "solicitudes" && <SolicitudesTab />}
          {tab === "documentos" && <DocumentosTab />}
          {tab === "perfil" && <PerfilTab />}
        </main>
      </div>
    </div>
  );
}

function ResumenTab() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="font-display text-3xl font-semibold text-[#243B32]">Bienvenida, Laura 👋</h1>
        <p className="text-[#6b7280] mt-1">Aquí tienes un resumen de tu actividad en Habita.</p>
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Favoritos guardados" value="3" icon="♥" trend="+1 esta semana" />
        <StatCard label="Citas agendadas" value="2" icon="📅" trend="1 próxima" />
        <StatCard label="Solicitudes enviadas" value="2" icon="✉" trend="1 en revisión" />
        <StatCard label="Documentos" value="1" icon="📄" />
      </div>

      <h2 className="font-display text-xl font-semibold text-[#243B32] mb-5">Próximas citas</h2>
      <div className="space-y-3 mb-8">
        {CITAS.filter(c => c.estado !== "Completada").map(c => (
          <Card key={c.id} className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-[#E8D8C4] flex flex-col items-center justify-center text-center">
              <span className="text-xs text-[#6b7280]">sep</span>
              <span className="font-display font-bold text-[#243B32] text-lg leading-none">{c.fecha.split(" ")[0]}</span>
            </div>
            <div className="flex-1">
              <p className="font-medium text-[#252525] text-sm">{c.propiedad}</p>
              <p className="text-xs text-[#6b7280]">{c.hora} · {c.asesor}</p>
            </div>
            <Badge label={c.estado} variant={c.estado === "Confirmada" ? "success" : "warning"} />
          </Card>
        ))}
      </div>

      <h2 className="font-display text-xl font-semibold text-[#243B32] mb-5">Favoritos recientes</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {FAVORITOS.map(f => (
          <Card key={f.id} className="overflow-hidden">
            <div className="h-36 bg-[#E8D8C4] overflow-hidden">
              <img src={f.img} alt={f.title} className="w-full h-full object-cover" />
            </div>
            <div className="p-4">
              <p className="font-display font-semibold text-[#C96E4B]">{f.price}</p>
              <p className="text-sm text-[#252525] mt-0.5 line-clamp-1">{f.title}</p>
              <p className="text-xs text-[#83946A] mt-0.5">📍 {f.city}</p>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

function FavoritosTab({ onNavigate }: { onNavigate: (v: string, e?: object) => void }) {
  const [items, setItems] = useState(FAVORITOS);
  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h1 className="font-display text-3xl font-semibold text-[#243B32]">Mis favoritos</h1>
        <Btn variant="outline" onClick={() => onNavigate("catalog")}>+ Agregar</Btn>
      </div>
      {items.length === 0 ? (
        <EmptyState icon="♡" title="Sin favoritos aún" description="Guarda propiedades que te interesen para verlas después." action={<Btn onClick={() => onNavigate("catalog")}>Explorar propiedades</Btn>} />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {items.map(f => (
            <Card key={f.id} className="overflow-hidden group">
              <div className="relative h-44 bg-[#E8D8C4]">
                <img src={f.img} alt={f.title} className="w-full h-full object-cover" />
                <Badge label={f.modalidad === "venta" ? "Venta" : "Arriendo"} variant={f.modalidad === "venta" ? "venta" : "arriendo"} />
                <button
                  onClick={() => setItems(items.filter(i => i.id !== f.id))}
                  className="absolute top-3 right-3 w-8 h-8 rounded-full bg-white/90 text-[#C96E4B] flex items-center justify-center text-sm hover:bg-red-50 transition-colors"
                >
                  ♥
                </button>
              </div>
              <div className="p-4">
                <p className="font-display font-semibold text-[#C96E4B]">{f.price}</p>
                <p className="text-sm font-medium text-[#252525] mt-0.5">{f.title}</p>
                <p className="text-xs text-[#83946A]">📍 {f.city}</p>
                <Btn size="sm" variant="outline" className="mt-3 w-full" onClick={() => onNavigate("detail", { id: f.id })}>Ver detalle</Btn>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}

function CitasTab() {
  return (
    <div>
      <h1 className="font-display text-3xl font-semibold text-[#243B32] mb-8">Mis citas</h1>
      <div className="space-y-3">
        {CITAS.map(c => (
          <Card key={c.id} className="p-5">
            <div className="flex items-start justify-between gap-4 flex-wrap">
              <div>
                <p className="font-semibold text-[#252525]">{c.propiedad}</p>
                <p className="text-sm text-[#6b7280] mt-1">{c.fecha} a las {c.hora} · Asesor: {c.asesor}</p>
              </div>
              <div className="flex items-center gap-3">
                <Badge label={c.estado} variant={c.estado === "Confirmada" ? "success" : c.estado === "Pendiente" ? "warning" : "neutral"} />
                {c.estado !== "Completada" && <Btn size="sm" variant="danger">Cancelar</Btn>}
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

function SolicitudesTab() {
  return (
    <div>
      <h1 className="font-display text-3xl font-semibold text-[#243B32] mb-8">Solicitudes enviadas</h1>
      <div className="overflow-x-auto rounded-2xl border border-[#ddd6c8]">
        <table className="w-full text-sm">
          <thead className="bg-[#E8D8C4]">
            <tr>
              {["Propiedad", "Inmobiliaria", "Fecha", "Estado", ""].map(h => (
                <th key={h} className="text-left px-5 py-3.5 font-semibold text-[#243B32] text-xs uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-[#f0e8dc]">
            {SOLICITUDES.map(s => (
              <tr key={s.id} className="hover:bg-[#F7F2E8] transition-colors">
                <td className="px-5 py-4 font-medium text-[#252525]">{s.propiedad}</td>
                <td className="px-5 py-4 text-[#6b7280]">{s.inmobiliaria}</td>
                <td className="px-5 py-4 text-[#6b7280]">{s.fecha}</td>
                <td className="px-5 py-4"><Badge label={s.estado} variant={s.estado === "Respondida" ? "success" : "warning"} /></td>
                <td className="px-5 py-4"><Btn size="sm" variant="ghost">Ver</Btn></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function DocumentosTab() {
  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h1 className="font-display text-3xl font-semibold text-[#243B32]">Documentos</h1>
        <Btn>+ Subir documento</Btn>
      </div>
      <Alert type="info" message="Sube tus documentos para agilizar el proceso de solicitud de arriendo o compra." />
      <div className="mt-6 space-y-3">
        {[
          { name: "Cédula de ciudadanía.pdf", size: "1.2 MB", date: "12 sep 2026", estado: "Verificado" },
          { name: "Desprendibles de nómina.pdf", size: "3.4 MB", date: "12 sep 2026", estado: "Pendiente" },
        ].map(d => (
          <Card key={d.name} className="p-4 flex items-center gap-4">
            <div className="w-10 h-10 rounded-xl bg-[#E8D8C4] flex items-center justify-center text-xl">📄</div>
            <div className="flex-1">
              <p className="font-medium text-[#252525] text-sm">{d.name}</p>
              <p className="text-xs text-[#6b7280]">{d.size} · {d.date}</p>
            </div>
            <Badge label={d.estado} variant={d.estado === "Verificado" ? "success" : "warning"} />
            <Btn size="sm" variant="ghost">Descargar</Btn>
          </Card>
        ))}
      </div>
      <div className="mt-8">
        <EmptyState
          icon="📎"
          title="Sube más documentos"
          description="Carta laboral, extractos bancarios, referencias personales."
          action={<Btn variant="outline">Seleccionar archivo</Btn>}
        />
      </div>
    </div>
  );
}

function PerfilTab() {
  const [saved, setSaved] = useState(false);
  return (
    <div className="max-w-xl">
      <h1 className="font-display text-3xl font-semibold text-[#243B32] mb-8">Mi perfil</h1>
      {saved && <div className="mb-5"><Alert type="success" message="Perfil actualizado correctamente." /></div>}
      <Card className="p-6 space-y-5">
        <div className="flex items-center gap-4 mb-2">
          <div className="w-16 h-16 rounded-2xl bg-[#C96E4B] flex items-center justify-center text-white font-display text-2xl font-bold">L</div>
          <div>
            <p className="font-semibold text-[#252525]">Laura Rodríguez</p>
            <p className="text-sm text-[#6b7280]">Cliente desde agosto 2025</p>
          </div>
          <Btn size="sm" variant="ghost" className="ml-auto">Cambiar foto</Btn>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="text-sm font-medium text-[#252525] block mb-1.5">Nombre</label>
            <input defaultValue="Laura" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
          </div>
          <div>
            <label className="text-sm font-medium text-[#252525] block mb-1.5">Apellido</label>
            <input defaultValue="Rodríguez" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
          </div>
        </div>
        <div>
          <label className="text-sm font-medium text-[#252525] block mb-1.5">Correo electrónico</label>
          <input defaultValue="laura@ejemplo.com" type="email" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
        </div>
        <div>
          <label className="text-sm font-medium text-[#252525] block mb-1.5">Teléfono</label>
          <input defaultValue="(+57) 314 789 0123" className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none" />
        </div>
        <div>
          <label className="text-sm font-medium text-[#252525] block mb-1.5">Ciudad de preferencia</label>
          <select className="w-full rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none">
            <option>Bogotá</option>
            <option>Medellín</option>
            <option>Cali</option>
          </select>
        </div>
        <div className="flex gap-3 pt-2">
          <Btn onClick={() => setSaved(true)}>Guardar cambios</Btn>
          <Btn variant="ghost">Cancelar</Btn>
        </div>
      </Card>
    </div>
  );
}
