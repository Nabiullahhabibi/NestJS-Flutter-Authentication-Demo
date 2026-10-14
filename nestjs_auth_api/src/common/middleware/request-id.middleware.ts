import { Injectable, NestMiddleware } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) { const id = req.header('x-request-id') ?? randomUUID(); res.setHeader('x-request-id', id); next(); }
}
