import {
  WebSocketGateway,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';

@WebSocketGateway({ cors: true })
export class EventsGateway {
  @SubscribeMessage('join_room')
  handleJoin(
    @MessageBody() data: any,
    @ConnectedSocket() client: Socket,
  ) {
    console.log('User joined room:', data);
  }

  @SubscribeMessage('update_location')
  handleLocation(@MessageBody() data: any) {
    console.log('Driver location:', data);
  }
}
