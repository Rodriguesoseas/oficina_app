const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

const EDGE_PATH = process.env.EDGE_PATH || 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const OUTPUT_DIR = path.resolve(__dirname, '..', 'oficina_api', 'docs', 'screenshots');

const ORANGE = '#E65100';
const BG = '#FAFAFA';
const CARD_BG = '#FFFFFF';

const screens = {};

screens.home = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; padding: 16px 20px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #E0E0E0;">
    <span style="font-size: 20px; font-weight: 600; color: #212121;">Oficina</span>
    <div style="display: flex; gap: 12px;">
      <span style="font-size: 20px; cursor: pointer;">&#128269;</span>
      <span style="font-size: 20px; cursor: pointer;">&#9790;</span>
    </div>
  </div>
  <div style="padding: 24px 20px 16px;">
    <div style="font-size: 22px; font-weight: 600; color: #212121;">Olá!</div>
    <div style="font-size: 14px; color: #757575; margin-top: 4px;">O que deseja fazer hoje?</div>
  </div>
  <div style="display: flex; gap: 12px; padding: 0 20px 20px;">
    <div style="flex: 1; background: white; border-radius: 12px; padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); text-align: center;">
      <div style="font-size: 28px; margin-bottom: 8px;">&#128100;</div>
      <div style="font-size: 13px; font-weight: 500; color: ${ORANGE};">Novo Cliente</div>
    </div>
    <div style="flex: 1; background: white; border-radius: 12px; padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); text-align: center;">
      <div style="font-size: 28px; margin-bottom: 8px;">&#128230;</div>
      <div style="font-size: 13px; font-weight: 500; color: ${ORANGE};">Estoque</div>
    </div>
  </div>
  <div style="padding: 0 20px 8px;">
    <div style="font-size: 14px; font-weight: 600; color: #424242;">Clientes</div>
  </div>
  <div style="padding: 0 16px;">
    ${['João Silva (11999999999)', 'Maria Santos (11988888888)', 'test2 (11699995555)', 'test3 (86900005555)'].map(n => `
      <div style="background: white; border-radius: 12px; padding: 12px 16px; margin-bottom: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.08); display: flex; align-items: center; gap: 12px;">
        <div style="width: 40px; height: 40px; border-radius: 50%; background: #FFF3E0; display: flex; align-items: center; justify-content: center; font-size: 18px; color: ${ORANGE};">&#128100;</div>
        <div style="flex: 1;">
          <div style="font-size: 14px; font-weight: 500;">${n.split(' (')[0]}</div>
          <div style="font-size: 12px; color: #757575;">${n.split(' (')[1]?.replace(')', '') || ''}</div>
        </div>
        <span style="color: #BDBDBD;">&#8250;</span>
      </div>
    `).join('')}
    <div style="text-align: center; padding: 12px 0; font-size: 13px; color: ${ORANGE}; font-weight: 500; cursor: pointer;">
      Ver todos os clientes →
    </div>
  </div>
</div>`;

screens.clientes_lista = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; padding: 16px 20px; display: flex; align-items: center; border-bottom: 1px solid #E0E0E0;">
    <span style="font-size: 18px; margin-right: 16px; cursor: pointer;">&#8592;</span>
    <span style="font-size: 18px; font-weight: 600; flex: 1;">Clientes</span>
    <span style="font-size: 24px; cursor: pointer; color: ${ORANGE};">+</span>
  </div>
  <div style="padding: 12px 16px;">
    <div style="background: #F5F5F5; border-radius: 12px; padding: 0 16px; display: flex; align-items: center;">
      <span style="color: #9E9E9E;">&#128269;</span>
      <input placeholder="Buscar cliente..." style="border: none; background: transparent; padding: 14px 12px; font-size: 14px; flex: 1; outline: none;">
    </div>
  </div>
  <div style="padding: 0 16px;">
    ${['João Silva', 'Maria Santos', 'test2', 'test3'].map(n => `
      <div style="background: white; border-radius: 12px; padding: 12px 16px; margin-bottom: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.08); display: flex; align-items: center; gap: 12px;">
        <div style="width: 40px; height: 40px; border-radius: 50%; background: #FFF3E0; display: flex; align-items: center; justify-content: center; font-size: 18px; color: ${ORANGE};">&#128100;</div>
        <div style="flex: 1;">
          <div style="font-size: 14px; font-weight: 500;">${n}</div>
          <div style="font-size: 12px; color: #757575;">Cliente</div>
        </div>
        <span style="color: #BDBDBD;">&#8250;</span>
      </div>
    `).join('')}
  </div>
</div>`;

screens.cliente_detalhe = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; padding: 16px 20px; display: flex; align-items: center; border-bottom: 1px solid #E0E0E0;">
    <span style="font-size: 18px; margin-right: 16px; cursor: pointer;">&#8592;</span>
    <span style="font-size: 18px; font-weight: 600; flex: 1;">João Silva</span>
    <span style="font-size: 18px; cursor: pointer;">&#9998;</span>
  </div>
  <div style="display: flex; flex-direction: column; align-items: center; padding: 32px 20px 24px; background: white; margin: 0 0 16px;">
    <div style="width: 64px; height: 64px; border-radius: 50%; background: #FFF3E0; display: flex; align-items: center; justify-content: center; font-size: 32px; color: ${ORANGE};">&#128100;</div>
    <div style="font-size: 18px; font-weight: 600; margin-top: 12px;">João Silva</div>
    <div style="font-size: 14px; color: #757575;">11999999999</div>
  </div>
  <div style="padding: 0 20px 8px; display: flex; align-items: center; justify-content: space-between;">
    <div style="font-size: 14px; font-weight: 600; color: #424242;">Motos (2)</div>
    <span style="font-size: 13px; color: ${ORANGE}; font-weight: 500; cursor: pointer;">Nova</span>
  </div>
  <div style="padding: 0 16px;">
    <div style="background: white; border-radius: 12px; padding: 12px 16px; margin-bottom: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.08); display: flex; align-items: center; gap: 12px;">
      <div style="width: 40px; height: 40px; border-radius: 50%; background: #E8F5E9; display: flex; align-items: center; justify-content: center; font-size: 18px; color: #2E7D32;">&#128690;</div>
      <div>
        <div style="font-size: 14px; font-weight: 500;">Honda CG 160 (ABC1234)</div>
        <div style="font-size: 12px; color: #757575;">15.000 km</div>
      </div>
    </div>
    <div style="background: white; border-radius: 12px; padding: 12px 16px; margin-bottom: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.08); display: flex; align-items: center; gap: 12px;">
      <div style="width: 40px; height: 40px; border-radius: 50%; background: #E8F5E9; display: flex; align-items: center; justify-content: center; font-size: 18px; color: #2E7D32;">&#128690;</div>
      <div>
        <div style="font-size: 14px; font-weight: 500;">Yamaha Fazer 250 (XYZ5678)</div>
        <div style="font-size: 12px; color: #757575;">30.000 km</div>
      </div>
    </div>
  </div>
</div>`;

screens.estoque_lista = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; padding: 16px 20px; display: flex; align-items: center; border-bottom: 1px solid #E0E0E0;">
    <span style="font-size: 18px; margin-right: 16px; cursor: pointer;">&#8592;</span>
    <span style="font-size: 18px; font-weight: 600; flex: 1;">Estoque</span>
    <span style="font-size: 24px; cursor: pointer; color: ${ORANGE};">+</span>
  </div>
  <div style="padding: 12px 16px;">
    <div style="background: ${ORANGE}10; border-radius: 12px; padding: 12px 16px; display: flex; justify-content: space-between;">
      <span style="font-size: 13px; color: #424242;">4 itens cadastrados</span>
      <span style="font-size: 13px; color: #D32F2F; font-weight: 500;">2 com estoque baixo</span>
    </div>
  </div>
  ${['Óleo', 'Pneus', 'Filtros'].map(cat => `
    <div style="padding: 8px 20px 4px; display: flex; align-items: center; gap: 8px;">
      <span style="font-size: 18px;">${cat === 'Óleo' ? '🛢️' : cat === 'Pneus' ? '⭕' : '🔧'}</span>
      <span style="font-size: 13px; font-weight: 600; color: #424242;">${cat}</span>
    </div>
    <div style="padding: 0 16px;">
      <div style="background: white; border-radius: 12px; padding: 12px 16px; margin-bottom: 6px; box-shadow: 0 1px 2px rgba(0,0,0,0.08);">
        <div style="display: flex; justify-content: space-between;">
          <div style="font-size: 14px; font-weight: 500;">${cat === 'Óleo' ? 'Mobil 20W50' : cat === 'Pneus' ? 'Pirelli 100/80' : 'Filtro de óleo'}</div>
          <div style="font-size: 13px; font-weight: 500;">R$ ${cat === 'Óleo' ? '35,00' : cat === 'Pneus' ? '150,00' : '18,00'}</div>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 6px;">
          <div style="display: flex; align-items: center; gap: 6px;">
            <span style="font-size: 12px; color: ${cat === 'Pneus' ? '#D32F2F' : '#388E3C'}; font-weight: 500;">${cat === 'Óleo' ? '50 em estoque' : cat === 'Pneus' ? '2 em estoque' : '15 em estoque'}</span>
            ${cat === 'Pneus' ? '<span style="font-size: 10px; background: #FFEBEE; color: #D32F2F; padding: 2px 6px; border-radius: 4px; font-weight: 600;">BAIXO</span>' : ''}
          </div>
          <span style="color: #BDBDBD;">&#9998;</span>
        </div>
      </div>
    </div>
  `).join('')}
</div>`;

screens.atendimento = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; padding: 16px 20px; display: flex; align-items: center; border-bottom: 1px solid #E0E0E0;">
    <span style="font-size: 18px; margin-right: 16px; cursor: pointer;">&#8592;</span>
    <span style="font-size: 18px; font-weight: 600;">Novo Atendimento</span>
  </div>
  <div style="padding: 16px;">
    <div style="background: white; border-radius: 16px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.08);">
      <div style="font-size: 14px; font-weight: 600; color: #424242; margin-bottom: 16px;">Dados do Cliente</div>
      <div style="margin-bottom: 12px;">
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Nome</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px; color: #212121;">João Silva</div>
      </div>
      <div>
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Telefone</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px; color: #212121;">11999999999</div>
      </div>
    </div>
    <div style="background: white; border-radius: 16px; padding: 20px; margin-top: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.08);">
      <div style="font-size: 14px; font-weight: 600; color: #424242; margin-bottom: 16px;">Serviço</div>
      <div style="margin-bottom: 12px;">
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Tipo de Serviço</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px; display: flex; justify-content: space-between;">
          <span>Troca de óleo</span>
          <span style="color: #9E9E9E;">▼</span>
        </div>
      </div>
      <div style="margin-bottom: 12px;">
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Valor mão de obra</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px;">R$ 50,00</div>
      </div>
      <div>
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Observação</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px; color: #9E9E9E;">Opcional</div>
      </div>
    </div>
    <div style="background: white; border-radius: 16px; padding: 20px; margin-top: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.08);">
      <div style="font-size: 14px; font-weight: 600; color: #424242; margin-bottom: 12px;">Peças</div>
      ${['Mobil 20W50 (R$ 35,00) × 2', 'Filtro de óleo (R$ 18,00) × 1'].map(item => `
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px; padding: 8px; background: #F5F5F5; border-radius: 8px;">
          <div style="flex: 1; font-size: 13px;">${item}</div>
          <span style="font-size: 16px; cursor: pointer; color: #D32F2F;">−</span>
          <span style="font-size: 12px; font-weight: 500;">${item.match(/× (\d+)/)[1]}</span>
          <span style="font-size: 16px; cursor: pointer; color: #388E3C;">+</span>
        </div>
      `).join('')}
      <div style="text-align: center; padding: 8px; font-size: 13px; color: ${ORANGE}; font-weight: 500; cursor: pointer;">+ Adicionar peça</div>
    </div>
    <button style="width: 100%; background: ${ORANGE}; color: white; border: none; border-radius: 12px; padding: 16px; font-size: 15px; font-weight: 600; margin-top: 16px; cursor: pointer;">Iniciar Atendimento</button>
  </div>
</div>`;

screens.os_detalhe = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; padding: 16px 20px; display: flex; align-items: center; border-bottom: 1px solid #E0E0E0;">
    <span style="font-size: 18px; margin-right: 16px; cursor: pointer;">&#8592;</span>
    <span style="font-size: 18px; font-weight: 600;">OS #93</span>
  </div>
  <div style="padding: 16px;">
    <div style="background: white; border-radius: 16px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.08);">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
        <div style="font-size: 14px; font-weight: 600;">Informações</div>
        <span style="font-size: 10px; background: #E8F5E9; color: #2E7D32; padding: 3px 8px; border-radius: 6px; font-weight: 600; border: 1px solid #A5D6A7;">FINALIZADA</span>
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
        <div><div style="font-size: 11px; color: #757575;">Cliente</div><div style="font-size: 13px; font-weight: 500;">test3</div></div>
        <div><div style="font-size: 11px; color: #757575;">Moto</div><div style="font-size: 13px; font-weight: 500;">pop 110 (nuss0000)</div></div>
        <div><div style="font-size: 11px; color: #757575;">Data</div><div style="font-size: 13px; font-weight: 500;">12/07/2026</div></div>
        <div><div style="font-size: 11px; color: #757575;">Prazo</div><div style="font-size: 13px; font-weight: 500;">16/07/2026</div></div>
      </div>
      <div style="margin-top: 12px;">
        <div style="font-size: 11px; color: #757575;">Problema relatado</div>
        <div style="font-size: 13px;">sada</div>
      </div>
    </div>

    <div style="background: white; border-radius: 16px; padding: 20px; margin-top: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.08);">
      <div style="font-size: 14px; font-weight: 600; margin-bottom: 12px;">Peças (1)</div>
      <div style="padding: 8px 0; border-bottom: 1px solid #EEEEEE; display: flex; justify-content: space-between;">
        <div>
          <div style="font-size: 13px; font-weight: 500;">pirreli</div>
          <div style="font-size: 12px; color: #757575;">3 x R$ 150,00</div>
        </div>
        <div style="font-size: 13px; font-weight: 500;">R$ 450,00</div>
      </div>
    </div>

    <div style="background: white; border-radius: 16px; padding: 20px; margin-top: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.08);">
      <div style="font-size: 14px; font-weight: 600; margin-bottom: 12px;">Valores</div>
      <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 8px;">
        <span style="color: #757575;">Peças</span>
        <span>R$ 450,00</span>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 8px;">
        <span style="color: #757575;">Mão de obra</span>
        <span>R$ 0,00</span>
      </div>
      <div style="border-top: 1px solid #EEEEEE; padding-top: 8px; display: flex; justify-content: space-between; font-size: 16px; font-weight: 700;">
        <span>Total</span>
        <span style="color: ${ORANGE};">R$ 450,00</span>
      </div>
    </div>
  </div>
</div>`;

screens.cliente_busca = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; border-bottom: 1px solid #E0E0E0;">
    <div style="display: flex;">
      <div style="flex: 1; padding: 14px; text-align: center; font-size: 14px; font-weight: 600; color: ${ORANGE}; border-bottom: 2px solid ${ORANGE};">Cliente</div>
      <div style="flex: 1; padding: 14px; text-align: center; font-size: 14px; color: #9E9E9E;">Placa</div>
    </div>
  </div>
  <div style="padding: 12px 16px;">
    <div style="background: #F5F5F5; border-radius: 12px; padding: 0 16px; display: flex; align-items: center;">
      <span style="color: #9E9E9E;">&#128269;</span>
      <input placeholder="Buscar por nome ou telefone..." style="border: none; background: transparent; padding: 14px 12px; font-size: 14px; flex: 1; outline: none;">
    </div>
  </div>
  <div style="padding: 0 16px;">
    ${['João Silva', 'Maria Santos', 'test2', 'test3'].map(n => `
      <div style="background: white; border-radius: 12px; padding: 12px 16px; margin-bottom: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.08); display: flex; align-items: center; gap: 12px;">
        <div style="width: 40px; height: 40px; border-radius: 50%; background: #FFF3E0; display: flex; align-items: center; justify-content: center; font-size: 18px; color: ${ORANGE};">&#128100;</div>
        <div style="flex: 1;">
          <div style="font-size: 14px; font-weight: 500;">${n}</div>
          <div style="font-size: 12px; color: #757575;">Cliente</div>
        </div>
        <span style="color: #BDBDBD;">&#8250;</span>
      </div>
    `).join('')}
  </div>
</div>`;

screens.estoque_form = `
<div style="font-family: 'Segoe UI', sans-serif; background: ${BG}; min-height: 800px; padding: 0; margin: 0;">
  <div style="background: white; padding: 16px 20px; display: flex; align-items: center; border-bottom: 1px solid #E0E0E0;">
    <span style="font-size: 18px; margin-right: 16px; cursor: pointer;">&#8592;</span>
    <span style="font-size: 18px; font-weight: 600;">Novo Item</span>
  </div>
  <div style="padding: 16px;">
    <div style="background: white; border-radius: 16px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.08);">
      <div style="margin-bottom: 12px;">
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Nome *</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px; border: 2px solid ${ORANGE};">Óleo 20W50</div>
      </div>
      <div style="margin-bottom: 12px;">
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Categoria *</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px; display: flex; justify-content: space-between;">
          <span>Óleo</span>
          <span style="color: #9E9E9E;">▼</span>
        </div>
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
        <div>
          <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Quantidade</label>
          <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px;">50</div>
        </div>
        <div>
          <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Estoque mínimo</label>
          <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px;">10</div>
        </div>
      </div>
      <div style="margin-bottom: 16px;">
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 4px;">Preço unitário</label>
        <div style="background: #F5F5F5; border-radius: 12px; padding: 14px 16px; font-size: 14px;">R$ 35,00</div>
      </div>
      <div style="margin-bottom: 16px;">
        <label style="font-size: 12px; color: #757575; display: block; margin-bottom: 8px;">Ativo</label>
        <div style="display: flex; background: #F5F5F5; border-radius: 12px; overflow: hidden;">
          <div style="flex: 1; padding: 10px; text-align: center; font-size: 13px; font-weight: 500; background: ${ORANGE}; color: white;">Sim</div>
          <div style="flex: 1; padding: 10px; text-align: center; font-size: 13px; color: #9E9E9E;">Não</div>
        </div>
      </div>
      <button style="width: 100%; background: ${ORANGE}; color: white; border: none; border-radius: 12px; padding: 16px; font-size: 15px; font-weight: 600; cursor: pointer;">Salvar</button>
    </div>
  </div>
</div>`;

async function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

async function captureScreen(page, name, html) {
  const fullHtml = `<!DOCTYPE html><html><body style="margin:0;padding:0;background:${BG};width:400px;">${html}</body></html>`;
  await page.setContent(fullHtml, { waitUntil: 'load', timeout: 10000 });
  await sleep(1000);
  const filePath = path.join(OUTPUT_DIR, `${name}.png`);
  await page.screenshot({ path: filePath, fullPage: true });
  console.log(`  ✓ ${name}.png`);
}

async function main() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const browser = await puppeteer.launch({
    executablePath: EDGE_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=400,800'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 400, height: 800 });

  console.log('Generating mockup screenshots...');
  for (const [name, html] of Object.entries(screens)) {
    await captureScreen(page, name, html);
  }

  await browser.close();
  console.log('\nAll screenshots generated in', OUTPUT_DIR);
}

main().catch(console.error);
